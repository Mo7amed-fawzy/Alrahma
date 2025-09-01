// utils/snackbar_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

class SnackbarHelper {
  static void show(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 2),
    Color? backgroundColor,
    Color textColor = Colors.white,
    double borderRadius = 16,
    SnackBarBehavior behavior = SnackBarBehavior.floating,
  }) {
    final snackBar = SnackBar(
      content: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: CustomTextStyles.cairoSemiBold16.copyWith(
            color: textColor,
            fontSize: 16.sp,
          ),
        ),
      ),

      duration: duration,
      backgroundColor:
          backgroundColor ?? AppColors.accentOrange, // هنا نحط الافتراضي

      behavior: behavior,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius.r),
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
