import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/assets.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/features/home/pages/home_page.dart';

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

    // ✅ بعد 3 ثواني ننتقل للصفحة الرئيسية
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(_createRoute());
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
    // ✅ نخلي اللوجو ريسبونسف بناءً على أصغر بُعد للشاشة
    final size = MediaQuery.of(context).size;
    final double logoHeight = min(size.width, size.height) * 0.35;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.lightGray,
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
                    Image.asset(
                      AppStyle.images.alRaham,
                      height: logoHeight,
                      fit: BoxFit.contain,
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
