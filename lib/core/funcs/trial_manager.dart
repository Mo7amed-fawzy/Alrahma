import 'package:alrahma/core/services/trial_service.dart';
import 'package:alrahma/core/services/trial_service_supabase.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class TrialManager {
  final TrialService _offlineService = TrialService();
  final TrialServiceSupabase _onlineService = TrialServiceSupabase();

  Future<Map<String, dynamic>> checkTrial() async {
    // تحقق من الاتصال
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = connectivityResult != ConnectivityResult.none;

    if (hasInternet) {
      try {
        // استخدم Supabase إذا فيه نت
        final result = await _onlineService.checkOrStartTrial();
        return {
          "source": "online",
          "status": result['status'],
          "remainingDays": result['remainingDays'],
        };
      } catch (e) {
        // لو فيه مشكلة بالإنترنت أو Supabase → fallback للـ offline
        print("❌ Online check failed: $e. Using offline.");
        return await _checkOffline();
      }
    } else {
      // مفيش نت → استخدم offline
      return await _checkOffline();
    }
  }

  Future<Map<String, dynamic>> _checkOffline() async {
    final remaining = await _offlineService.remainingDays();
    final status = remaining > 0 ? 'active' : 'expired';
    return {"source": "offline", "status": status, "remainingDays": remaining};
  }
}
