// lib/core/services/update_checker.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class UpdateInfo {
  final String latestVersion;
  final String apkUrl;
  final bool forceUpdate;

  UpdateInfo({
    required this.latestVersion,
    required this.apkUrl,
    required this.forceUpdate,
  });
}

class UpdateChecker {
  static bool _isChecking = false;

  /// تجيب آخر صف من جدول updates
  static Future<UpdateInfo?> fetchLatestUpdate() async {
    if (_isChecking) return null;
    _isChecking = true;

    try {
      final supabase = Supabase.instance.client;

      // نستخدم .maybeSingle() لأن API قد يرجع null في حالة عدم وجود صف
      final res = await supabase
          .from('updates')
          .select('version, apk_url, force_update')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res == null) return null;

      // تأكد من تعاملك مع أنواع مختلفة (int أو text)
      final latestVersion = (res['version'] ?? '').toString();
      final apkUrl = (res['apk_url'] ?? '').toString();
      final force = (res['force_update'] ?? false) as bool;

      debugPrint('📦 Latest Version from Supabase: $latestVersion');

      return UpdateInfo(
        latestVersion: latestVersion,
        apkUrl: apkUrl,
        forceUpdate: force,
      );
    } catch (e, st) {
      debugPrint("❌ Error fetching latest update: $e\n$st");
      return null;
    } finally {
      _isChecking = false;
    }
  }

  /// قارن بين نسختين بصيغة semantic (1.0.8 vs 1.0.5)
  static bool isUpdateAvailable(String current, String latest) {
    List<int> parseVersion(String v) {
      return v.split('.').map((e) {
        return int.tryParse(e) ?? 0;
      }).toList();
    }

    final curr = parseVersion(current);
    final newV = parseVersion(latest);

    for (int i = 0; i < newV.length; i++) {
      final c = i < curr.length ? curr[i] : 0;
      if (newV[i] > c) return true;
      if (newV[i] < c) return false;
    }
    return false;
  }

  static void stop() {
    _isChecking = false;
  }
}
