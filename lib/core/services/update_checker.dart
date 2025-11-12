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

  /// 🔍 تجلب آخر تحديث من جدول updates
  static Future<UpdateInfo?> fetchLatestUpdate() async {
    if (_isChecking) return null;
    _isChecking = true;

    try {
      final supabase = Supabase.instance.client;

      final res = await supabase
          .from('updates')
          .select('version, apk_url, force_update')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (res == null) return null;

      final latestVersion = (res['version'] ?? '').toString();
      final apkUrl = (res['apk_url'] ?? '').toString();
      final force = (res['force_update'] ?? false) as bool;

      debugPrint('📦 Latest version: $latestVersion');
      debugPrint('🔗 APK URL: $apkUrl');

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

  /// ⚖️ مقارنة رقم الإصدار الحالي بالمتوفر على السيرفر
  static bool isUpdateAvailable(String current, String latest) {
    List<int> parse(String v) =>
        v.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final c = parse(current);
    final l = parse(latest);

    for (int i = 0; i < l.length; i++) {
      final curr = i < c.length ? c[i] : 0;
      if (l[i] > curr) return true;
      if (l[i] < curr) return false;
    }
    return false;
  }

  static void stop() => _isChecking = false;
}
