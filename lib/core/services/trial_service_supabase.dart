// lib/core/services/trial_service_supabase.dart
import 'dart:async';
import 'dart:math';

import 'package:alrahma/core/utils/print_statement.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// خدمة الترايل باستخدام Supabase — نسخة متوافقة مع الجدول الموجود.
/// الجدول المتوقع (كما عندك):
/// CREATE TABLE public.trials (
///   device_id TEXT PRIMARY KEY,
///   start_date TIMESTAMP WITH TIME ZONE NOT NULL,
///   is_blocked BOOLEAN NOT NULL DEFAULT false,
///   status TEXT NOT NULL,
///   user_name TEXT
/// );
///
/// ملاحظات:
/// - لا نغير في الـ schema — الكود يملأ فقط الحقول المتوفرة.
/// - لو لم يكن هناك duration_days أو created_at في الجدول، يعتبر الترايل "لا نهائي".
class TrialServiceSupabase {
  final SupabaseClient _client = Supabase.instance.client;

  // مفتاح التخزين المحلي لمعرفة الجهاز
  static const String _kLocalDeviceIdKey = 'alrahma_device_id';

  // عدد المحاولات لإعادة المحاولة عند فشل الشبكة
  static const int _maxRetries = 3;

  // مدة الانتظار الابتدائية لإعادة المحاولة (ms)
  static const int _initialBackoffMs = 500;

  /// الفنكشن الرئيسي: يتحقق من حالة الترايل أو يبدأه إن لم يكن موجودًا.
  /// يعيد Map يحتوي status (active|blocked_device|expired) و remainingDays.
  Future<Map<String, dynamic>> checkOrStartTrial() async {
    final deviceId = await _getOrCreateDeviceId();

    // Logging
    printHere('🔎 deviceId (used for trial): $deviceId');

    try {
      // 1) Fetch the device row (with retry)
      final fetch = await _retryRequest(() async {
        return await _client
            .from('trials')
            .select()
            .eq('device_id', deviceId)
            .maybeSingle();
      });

      // 2) If not found -> create a new trial row (upsert)
      if (fetch == null) {
        printHere('➕ No trial row found for device -> creating new row');

        // Prepare payload compatible with your table (note: start_date is required)
        final payload = {
          "device_id": deviceId,
          "start_date": DateTime.now().toUtc().toIso8601String(),
          "is_blocked": false,
          "status": "active",
          // "user_name": null, // optional
        };

        // Try upsert with return representation
        final inserted = await _retryRequest(() async {
          final resp = await _client
              .from('trials')
              .upsert(payload, onConflict: 'device_id')
              .select()
              .maybeSingle();
          return resp;
        });

        if (inserted == null) {
          // Fallback: try plain insert (some Postgrest setups might not return representation)
          printHere(
            '⚠️ Upsert returned null — trying insert then select fallback',
          );
          await _retryRequest(() async {
            await _client.from('trials').insert(payload);
            return true;
          });

          // fetch again
          final reFetch = await _retryRequest(() async {
            return await _client
                .from('trials')
                .select()
                .eq('device_id', deviceId)
                .maybeSingle();
          });

          if (reFetch == null) {
            // إذا فشل كل شيء — افترض تفعيل محلياً (trial لا نهائي)
            printHere(
              '❗ Failed to persist trial on server — falling back to local active',
            );
            return {"status": "active", "remainingDays": double.infinity};
          } else {
            return _prepareTrialResponseFromRow(reFetch);
          }
        } else {
          return _prepareTrialResponseFromRow(inserted);
        }
      }

      // 3) If device row exists
      return _prepareTrialResponseFromRow(fetch);
    } catch (e, st) {
      printHere('❌ checkOrStartTrial error: $e\n$st');
      // fallback conservative: active unlimited
      return {"status": "active", "remainingDays": double.infinity};
    }
  }

  /// يحضر الاستجابة النهائية بناءً على صف من DB
  Map<String, dynamic> _prepareTrialResponseFromRow(Map<String, dynamic> row) {
    try {
      // إذا الحقل is_blocked موجود وكان true -> محظور
      final isBlocked = (row['is_blocked'] == true);
      if (isBlocked) {
        printHere('⛔ Device is blocked in DB');
        return {"status": "blocked_device", "remainingDays": 0};
      }

      // نحاول قراءة start_date (موجود في جدولك) و duration_days (قد لا يكون موجود)
      final startDateStr = row['start_date'] is String
          ? row['start_date'] as String
          : (row['start_date']?.toString());

      final durationDays = row['duration_days'] is int
          ? (row['duration_days'] as int)
          : (row['duration_days'] is num
                ? (row['duration_days'] as num).toInt()
                : null);

      // إذا وجد start_date و duration_days -> نحسب المتبقي
      if (startDateStr != null && durationDays != null) {
        try {
          final startDate = DateTime.parse(startDateStr).toUtc();
          final endDate = startDate.add(Duration(days: durationDays));
          final nowUtc = DateTime.now().toUtc();
          final remaining = endDate.isAfter(nowUtc)
              ? ((endDate.difference(nowUtc).inHours) / 24.0)
              : 0.0;
          final status = remaining > 0 ? 'active' : 'expired';
          printHere(
            '📅 Trial start: $startDateStr, duration: $durationDays, remainingDays: ${remaining.ceil()}',
          );
          return {
            'status': status,
            'remainingDays': remaining.isFinite ? remaining : double.infinity,
          };
        } catch (e) {
          printHere('⚠️ Error parsing start_date/duration_days: $e');
          return {"status": "active", "remainingDays": double.infinity};
        }
      }

      // افتراض افتراضي: لو مافي duration_days نعتبر الترايل لا نهائي (كما طلبت)
      return {"status": "active", "remainingDays": double.infinity};
    } catch (e) {
      printHere('⚠️ _prepareTrialResponseFromRow error: $e');
      return {"status": "active", "remainingDays": double.infinity};
    }
  }

  /// محاولة استدعاء الشبكة مع retry و exponential backoff
  Future<T?> _retryRequest<T>(Future<T> Function() fn) async {
    int attempt = 0;
    while (true) {
      try {
        final result = await fn();
        return result;
      } catch (e) {
        attempt++;
        if (attempt >= _maxRetries) {
          printHere('🔁 Retry: failed after $attempt attempts. Error: $e');
          rethrow;
        }
        final backoff = _initialBackoffMs * pow(2, attempt - 1);
        printHere(
          '🔁 Retry attempt $attempt after ${backoff}ms due to error: $e',
        );
        await Future.delayed(Duration(milliseconds: backoff.toInt()));
      }
    }
  }

  /// الحصول على معرف الجهاز — مع حفظ محلي لضمان الثبات
  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    final stored = prefs.getString(_kLocalDeviceIdKey);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored;
    }

    final deviceInfo = DeviceInfoPlugin();
    try {
      final android = await deviceInfo.androidInfo;
      final candidate = (android.id ?? '').toString().trim();
      if (candidate.isNotEmpty) {
        await prefs.setString(_kLocalDeviceIdKey, candidate);
        printHere('📱 Saved deviceId (android): $candidate');
        return candidate;
      }
    } catch (e) {
      printHere('⚠️ androidInfo fetch failed: $e');
    }

    try {
      final ios = await deviceInfo.iosInfo;
      final candidate = (ios.identifierForVendor ?? '').toString().trim();
      if (candidate.isNotEmpty) {
        await prefs.setString(_kLocalDeviceIdKey, candidate);
        printHere('📱 Saved deviceId (ios): $candidate');
        return candidate;
      }
    } catch (e) {
      printHere('⚠️ iosInfo fetch failed: $e');
    }

    final fallback = _generateFallbackId();
    await prefs.setString(_kLocalDeviceIdKey, fallback);
    printHere('🛡️ Generated fallback deviceId: $fallback');
    return fallback;
  }

  String _generateFallbackId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final rnd = Random().nextInt(1000000);
    return 'device_${ts}_$rnd';
  }
}
