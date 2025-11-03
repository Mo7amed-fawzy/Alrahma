import 'package:flutter/material.dart';

class PremiumRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? backgroundColor;
  final Color? indicatorColor;
  final double? strokeWidth;
  final double? displacement;
  final double? triggerDistance;
  final bool showIcon;
  final double? iconSize;
  final bool useFadeTransition;
  final bool useShadowEffect;
  final bool useLinearProgress;
  final double? progressValue;

  const PremiumRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.backgroundColor,
    this.indicatorColor,
    this.strokeWidth = 3.0,
    this.displacement = 40.0,
    this.triggerDistance = 100.0,
    this.showIcon = true,
    this.iconSize = 24.0,
    this.useFadeTransition = false,
    this.useShadowEffect = false,
    this.useLinearProgress = false,
    this.progressValue = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      backgroundColor: backgroundColor ?? Colors.black,
      color: indicatorColor ?? Colors.amber,
      strokeWidth: strokeWidth!,
      displacement: displacement!,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      child: Builder(
        builder: (context) {
          return Stack(
            alignment: Alignment.center,
            children: [
              child,
              if (useFadeTransition) _buildFadeTransition(context),
              if (showIcon) _buildAnimatedIcon(),
              if (useLinearProgress) _buildLinearProgress(),
              if (useShadowEffect) _buildShadowEffect(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFadeTransition(BuildContext context) {
    final animation = ModalRoute.of(context)?.animation;
    if (animation == null) return child;

    return FadeTransition(
      opacity: Tween(
        begin: 1.0,
        end: 0.3,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeIn)),
      child: child,
    );
  }

  Widget _buildAnimatedIcon() {
    return AnimatedRotation(
      turns: 1 / 2,
      duration: Duration(milliseconds: 600),
      child: Icon(
        Icons.refresh,
        size: iconSize,
        color: Colors.white.withAlpha((0.8 * 255).toInt()),
      ),
    );
  }

  Widget _buildLinearProgress() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: LinearProgressIndicator(
        value: progressValue,
        backgroundColor: Colors.black.withAlpha((0.3 * 255).toInt()),
        valueColor: AlwaysStoppedAnimation<Color>(
          indicatorColor ?? Colors.amber,
        ),
      ),
    );
  }

  Widget _buildShadowEffect() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withAlpha((0.5 * 255).toInt()),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha((0.5 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          indicatorColor ?? Colors.amber,
        ),
        strokeWidth: strokeWidth!,
      ),
    );
  }
}

class CustomRefreshChild extends StatelessWidget {
  final Widget child;
  final bool showIcon;
  final double iconSize;

  const CustomRefreshChild({
    super.key,
    required this.child,
    required this.showIcon,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (showIcon)
          AnimatedRotation(
            turns: 1 / 2,
            duration: Duration(milliseconds: 600),
            child: Icon(
              Icons.refresh,
              size: iconSize,
              color: Colors.white.withAlpha((0.8 * 255).toInt()),
            ),
          ),
      ],
    );
  }
}
