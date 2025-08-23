import 'package:flutter/material.dart';

class PremiumLoader extends StatefulWidget {
  final bool isLoading;
  final String? message;
  final TextStyle? messageTextStyle; // تمت إضافتها للتحكم بالخط
  final Color? color;
  final double size;
  final bool showIcon;
  final bool
  isUserInteractionEnabled; // لتفعيل أو تعطيل التفاعل مع واجهة المستخدم
  final bool showGlowEffect; // لتفعيل تأثير التوهج
  final String stateIndicator; // "loading", "success", "failure"
  final bool isDarkMode; // لتفعيل الوضع المظلم
  final Function? onDone; // إغلاق أو إيقاف التحميل عند الحاجة

  const PremiumLoader({
    super.key,
    required this.isLoading,
    this.message,
    this.messageTextStyle,
    this.color = Colors.blue,
    this.size = 50.0,
    this.showIcon = true,
    this.isUserInteractionEnabled = true,
    this.showGlowEffect = true,
    this.stateIndicator = 'loading', // القيمة الافتراضية: "loading"
    this.isDarkMode = false,
    this.onDone,
  });

  @override
  PremiumLoaderState createState() => PremiumLoaderState();
}

class PremiumLoaderState extends State<PremiumLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween(begin: 0.8, end: 1.2).animate(_animationController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
        }
      });
    if (widget.isLoading) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color loaderColor = widget.isDarkMode ? Colors.white : widget.color!;
    final Color defaultTextColor = widget.isDarkMode
        ? Colors.white
        : Colors.black;

    return GestureDetector(
      onTap: widget.isUserInteractionEnabled ? null : () {},
      child: AbsorbPointer(
        absorbing: !widget.isUserInteractionEnabled,
        child: widget.isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Container(
                          height: widget.size,
                          width: widget.size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: loaderColor,
                            boxShadow: widget.showGlowEffect
                                ? [
                                    BoxShadow(
                                      color: loaderColor.withAlpha(128),
                                      blurRadius: 8.0,
                                      spreadRadius: 6.0,
                                    ),
                                  ]
                                : [],
                          ),
                          child: widget.showIcon
                              ? Icon(
                                  Icons.hourglass_empty,
                                  size: widget.size * 0.5,
                                  color: Colors.white,
                                )
                              : Container(),
                        );
                      },
                    ),
                    if (widget.message != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          widget.message!,
                          style:
                              widget.messageTextStyle ??
                              TextStyle(
                                color: defaultTextColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    if (widget.stateIndicator == 'success')
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: widget.size,
                      ),
                    if (widget.stateIndicator == 'failure')
                      Icon(Icons.error, color: Colors.red, size: widget.size),
                  ],
                ),
              )
            : Container(),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
