import 'package:flutter/material.dart';
import 'package:tabea/core/funcs/init_and_load_databases.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'package:tabea/core/utils/custom_text_styles.dart';
import 'package:tabea/features/splash_trail/widgets/show_trial_ended_dialog.dart';

class WelcomeMessage extends StatefulWidget {
  const WelcomeMessage({super.key});

  @override
  State<WelcomeMessage> createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<WelcomeMessage> {
  int _remainingDays = 0;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingDays();
  }

  Future<void> _calculateRemainingDays() async {
    final prefs = DatabasesNames.clientsPrefs;

    dynamic firstLaunchData = await prefs.getData('firstLaunchDate');
    DateTime firstLaunch;

    if (firstLaunchData == null) {
      firstLaunch = DateTime.now().toUtc();
      await prefs.setData('firstLaunchDate', firstLaunch.toIso8601String());
    } else {
      firstLaunch = DateTime.parse(firstLaunchData.toString());
    }

    final now = DateTime.now().toUtc();
    final difference = now.difference(firstLaunch).inDays;

    setState(() {
      _remainingDays = 7 - difference;
      if (_remainingDays < 0) _remainingDays = 0;
    });

    if (_remainingDays <= 0 && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTrialEndedDialog(context);
      });
    }
  }

  Future<void> _calculateRemainingDaysExpire() async {
    final prefs = DatabasesNames.clientsPrefs;

    dynamic firstLaunchData = await prefs.getData('firstLaunchDate');
    DateTime firstLaunch;

    if (firstLaunchData == null) {
      firstLaunch = DateTime.now().toUtc();
      await prefs.setData('firstLaunchDate', firstLaunch.toIso8601String());
    } else {
      firstLaunch = DateTime.parse(firstLaunchData.toString());
    }

    // هنا نجرب انتهاء الفترة فوراً
    setState(() {
      _remainingDays = 0; // يعتبر التطبيق منتهي الفترة المجانية
    });

    // إذا أردت إظهار Dialog مباشرة عند انتهاء الفترة:
    if (_remainingDays <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTrialEndedDialog(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.85),
            AppColors.primaryBlue.withValues(alpha: 0.65),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.dashboard_customize, size: 36, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا بك في لوحة التحكم، تابع أداء عملك بسهولة!',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                if (_remainingDays > 0)
                  Text(
                    'متبقي من فترة التجربة: $_remainingDays يوم/أيام',
                    style: CustomTextStyles.cairoRegular14.copyWith(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                if (_remainingDays <= 0)
                  Text(
                    'انتهت فترة التجربة',
                    style: CustomTextStyles.cairoRegular14.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
