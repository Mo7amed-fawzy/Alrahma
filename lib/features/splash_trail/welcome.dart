import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/core/utils/assets.dart';
import 'package:alrahma/features/splash_trail/widgets/show_trial_ended_dialog.dart';
import 'package:alrahma/core/services/trial_service.dart'; // ✅ السيرفيس

class WelcomeMessage extends StatefulWidget {
  const WelcomeMessage({super.key});

  @override
  State<WelcomeMessage> createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<WelcomeMessage> {
  int _remainingDays = 0;
  bool _dialogShown = false;
  final TrialService _trialService = TrialService();

  @override
  void initState() {
    super.initState();
    _initTrial();
  }

  Future<void> _initTrial() async {
    await _trialService.init();
    await _trialService.startTrial();

    final expired = await _trialService.isTrialExpired();
    final remaining = await _trialService.remainingDays();

    setState(() {
      _remainingDays = remaining;
    });

    debugPrint("📌 Remaining days: $_remainingDays | Expired: $expired");

    if (expired && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTrialEndedDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 📱 نسبية حسب حجم الشاشة
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
                if (_remainingDays > 0)
                  Text(
                    'متبقي من فترة التجربة: $_remainingDays يوم/أيام',
                    style: CustomTextStyles.cairoRegular14.copyWith(
                      color: Colors.white70,
                      fontSize: baseSize,
                    ),
                  ),
                if (_remainingDays <= 0)
                  Text(
                    'انتهت فترة التجربة',
                    style: CustomTextStyles.cairoRegular14.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
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
