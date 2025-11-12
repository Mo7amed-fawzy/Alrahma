import 'package:alrahma/core/utils/print_statement.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UpdateChecker {
  static bool _isChecking = false;

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

      final latestVersion = response['version']
          .toString(); // 👈 مهم نخليها String
      final apkUrl = response['apk_url'] as String;
      final force = response['force_update'] as bool;

      printHere('📦 Latest Version from Supabase: $latestVersion');
      return UpdateInfo(
        latestVersion: latestVersion,
        apkUrl: apkUrl,
        forceUpdate: force,
      );
    } catch (e, st) {
      printHere("❌ Error fetching latest update: $e\n$st");
      return null;
    } finally {
      _isChecking = false;
    }
  }

  /// ✅ دالة المقارنة الذكية بين الإصدارات
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
