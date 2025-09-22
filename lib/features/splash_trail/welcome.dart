import 'package:alrahma/core/services/trial_service_supabase.dart';
import 'package:alrahma/core/services/trial_service.dart';
import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/core/utils/assets.dart';
import 'package:alrahma/features/splash_trail/widgets/show_trial_ended_dialog.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class WelcomeMessage extends StatefulWidget {
  const WelcomeMessage({super.key});

  @override
  State<WelcomeMessage> createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<WelcomeMessage> {
  int _remainingDays = 0;
  bool _dialogShown = false;

  final TrialService _offlineService = TrialService();
  final TrialServiceSupabase _onlineService = TrialServiceSupabase();

  @override
  void initState() {
    super.initState();
    _checkTrial();
  }

  Future<void> _checkTrial() async {
    try {
      // تحقق من الاتصال بالإنترنت
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasInternet = connectivityResult != ConnectivityResult.none;

      Map<String, dynamic> result;

      if (hasInternet) {
        try {
          // online
          result = await _onlineService.checkOrStartTrial();
          result['source'] = 'online';
          _log("Using online trial source.");
        } catch (e) {
          print("❌ Online check failed: $e. Falling back to offline.");
          result = await _checkOffline();
        }
      } else {
        result = await _checkOffline();
      }

      _handleTrialResult(result);
    } catch (e) {
      debugPrint("❌ Trial check failed: $e");
      if (!_dialogShown) {
        _dialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showTrialEndedDialog(context);
        });
      }
    }
  }

  Future<Map<String, dynamic>> _checkOffline() async {
    final remaining = await _offlineService.remainingDays();
    final status = remaining > 0 ? 'active' : 'expired';
    _log("Using offline trial source. Remaining days: $remaining");
    return {"source": "offline", "status": status, "remainingDays": remaining};
  }

  void _handleTrialResult(Map<String, dynamic> result) {
    final status = result['status'] as String;
    final remaining = result['remainingDays'] as int;

    if (!mounted) return;
    setState(() {
      _remainingDays = remaining;
    });

    if (status == 'expired' && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTrialEndedDialog(context);
      });
    }
  }

  void _log(String message) {
    print("[WelcomeMessage] $message");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSize = screenWidth * 0.04;

    return Container(
      margin: EdgeInsets.only(bottom: baseSize * 0.8),
      padding: EdgeInsets.all(baseSize),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.95),
            AppColors.lightGray.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(baseSize * 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: baseSize * 1.2,
            spreadRadius: baseSize * 0.2,
            offset: Offset(0, baseSize * 0.4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AppStyle.images.alRaham,
            height: screenHeight * 0.08,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.dashboard_customize,
                size: screenHeight * 0.06,
                color: Colors.white,
              );
            },
          ),
          SizedBox(width: baseSize),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا بك في الرحمة، تابع أداء عملك بسهولة!',
                  softWrap: true,
                  style: CustomTextStyles.cairoBold20.copyWith(
                    fontSize: baseSize * 1.2,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: baseSize * 0.3,
                        offset: Offset(baseSize * 0.1, baseSize * 0.1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: baseSize * 0.3),
                Text(
                  'انجز مهامك بسهولة!',
                  style: CustomTextStyles.cairoRegular14.copyWith(
                    color: Colors.white70,
                    fontSize: baseSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
