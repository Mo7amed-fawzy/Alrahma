import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';

class TrialServiceSupabase {
  final SupabaseClient _client = Supabase.instance.client;
  final int defaultTrialDays;

  TrialServiceSupabase({this.defaultTrialDays = 7});

  /// الحصول على معرف الجهاز
  Future<String> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } catch (_) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? "unknown_ios";
    }
  }

  /// التحقق أو بدء الترايل للجهاز الحالي
  Future<Map<String, dynamic>> checkOrStartTrial() async {
    final deviceId = await _getDeviceId();

    try {
      // محاولة جلب السطر الموجود مسبقاً
      final fetch = await _client
          .from('trials')
          .select()
          .eq('device_id', deviceId)
          .maybeSingle();

      final nowUtc = DateTime.now().toUtc();

      if (fetch == null) {
        // الجهاز جديد → سجل الترايل
        try {
          final upsertResp = await _client
              .from('trials')
              .upsert({
                'device_id': deviceId,
                'duration_days': defaultTrialDays,
                'status': 'active',
              }, onConflict: 'device_id')
              .select()
              .maybeSingle();

          if (upsertResp == null) {
            throw Exception(
              'Failed to insert trial row (upsert returned null).',
            );
          }

          final startDateStr = upsertResp['start_date'] as String?;
          final duration =
              upsertResp['duration_days'] as int? ?? defaultTrialDays;
          final startDate = startDateStr != null
              ? DateTime.parse(startDateStr).toUtc()
              : nowUtc;
          final endDate = startDate.add(Duration(days: duration));
          final remaining = endDate.isAfter(nowUtc)
              ? ((endDate.difference(nowUtc).inHours) / 24).ceil()
              : 0;

          return {'status': 'active', 'remainingDays': remaining};
        } catch (e) {
          print("⚠️ Failed to insert trial on server: $e");
          // fallback → start locally بدون data من السيرفر
          return {'status': 'active', 'remainingDays': defaultTrialDays};
        }
      } else {
        // الجهاز موجود → احسب الأيام المتبقية
        final startDateStr = fetch['start_date'] as String?;
        final duration = fetch['duration_days'] as int? ?? defaultTrialDays;
        final startDate = startDateStr != null
            ? DateTime.parse(startDateStr).toUtc()
            : nowUtc;
        final endDate = startDate.add(Duration(days: duration));
        final remaining = endDate.isAfter(nowUtc)
            ? ((endDate.difference(nowUtc).inHours) / 24).ceil()
            : 0;
        final status = remaining > 0 ? 'active' : 'expired';

        // تحديث الحالة لو انتهت التجربة
        if (status != (fetch['status'] as String? ?? 'active')) {
          try {
            await _client
                .from('trials')
                .update({'status': status})
                .eq('device_id', deviceId)
                .select()
                .maybeSingle();
          } catch (e) {
            print("⚠️ Failed to update status on server: $e");
          }
        }

        return {'status': status, 'remainingDays': remaining};
      }
    } catch (e) {
      print("❌ Failed to check trial: $e");
      // fallback → start locally بدون data من السيرفر
      return {'status': 'active', 'remainingDays': defaultTrialDays};
    }
  }
}
