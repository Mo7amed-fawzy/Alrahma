import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class UpdateInfo {
  final String latestVersion; // دلوقتي نص بدل int
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

  /// 🔍 تجيب آخر إصدار من جدول Supabase
  static Future<UpdateInfo?> fetchLatestUpdate() async {
    if (_isChecking) return null;
    _isChecking = true;

    try {
      final supabase = Supabase.instance.client;

      final response = await supabase
          .from('updates')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .single();

      // version دلوقتي نص بدل int
      final latestVersion = response['version'] as String;
      final apkUrl = response['apk_url'] as String;
      final force = response['force_update'] as bool;

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

  /// ✅ مقارنة النسخة الحالية مع النسخة الجديدة
  static bool isUpdateAvailable(String currentVersion, String latestVersion) {
    try {
      final currentParts = currentVersion.split('.').map(int.parse).toList();
      final latestParts = latestVersion.split('.').map(int.parse).toList();

      for (var i = 0; i < currentParts.length; i++) {
        if (i >= latestParts.length) break;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }

      return latestParts.length > currentParts.length;
    } catch (e) {
      debugPrint("❌ Error comparing versions: $e");
      return false;
    }
  }

  static void stop() {
    _isChecking = false;
  }
}
