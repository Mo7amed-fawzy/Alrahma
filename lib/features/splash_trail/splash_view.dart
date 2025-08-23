import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'package:tabea/core/utils/custom_text_styles.dart';
import 'package:tabea/features/home/pages/home_page.dart';
import 'package:tabea/features/splash_trail/trial_expired_page.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    // Timer بعد 3 ثواني للتحقق من الـ Trial
    Timer(const Duration(seconds: 3), () async {
      final prefs = await SharedPreferences.getInstance();

      // تخزين تاريخ أول تشغيل إذا مش موجود
      if (!prefs.containsKey('firstLaunchDate')) {
        prefs.setString(
          'firstLaunchDate',
          DateTime.now().toUtc().toIso8601String(),
        );
      }

      final firstLaunch = DateTime.parse(prefs.getString('firstLaunchDate')!);
      final now = DateTime.now().toUtc();
      final difference = now.difference(firstLaunch).inDays;

      if (difference >= 7) {
        // لو Trial انتهت
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const TrialExpiredPage()),
        );
      } else {
        // لو Trial لسه شغالة
        Navigator.of(context).pushReplacement(_createRoute());
      }
    });
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomeView(),
      transitionDuration: const Duration(milliseconds: 800),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return SlideTransition(position: tween, child: child);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primaryBlue,
        body: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.dashboard_customize,
                      size: 50,
                      color: AppColors.textOnDark,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'تابع',
                      style: CustomTextStyles.cairoBold20.copyWith(
                        fontSize: 36,
                        color: AppColors.textOnDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
