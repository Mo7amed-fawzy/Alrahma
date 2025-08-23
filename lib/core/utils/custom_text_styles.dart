import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

abstract class CustomTextStyles {
  // ---------- Cairo Bold ----------
  static final cairoBold20 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.bold,
    fontSize: 20.sp,
    color: AppColors.textPrimary,
  );

  static final cairoBold24 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.bold,
    fontSize: 24.sp,
    color: AppColors.textPrimary,
  );

  // ---------- Cairo SemiBold ----------
  static final cairoSemiBold18 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w600,
    fontSize: 18.sp,
    color: AppColors.textPrimary,
  );

  static final cairoSemiBold16 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    color: AppColors.textPrimary,
  );

  // ---------- Cairo Regular ----------
  static final cairoRegular14 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.normal,
    fontSize: 14.sp,
    color: AppColors.textPrimary,
  );

  static final cairoRegular16 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.normal,
    fontSize: 16.sp,
    color: AppColors.textSecondary,
  );

  static final cairoRegular18 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.normal,
    fontSize: 18.sp,
    color: AppColors.textPrimary,
  );

  // ---------- Cairo Light ----------
  static final cairoLight14 = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w300,
    fontSize: 14.sp,
    color: AppColors.textSecondary,
  );

  // ---------- Text for Buttons / Cards ----------
  static final buttonText = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.bold,
    fontSize: 16.sp,
    color: AppColors.textOnDark,
  );

  static final cardTitle = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.bold,
    fontSize: 18.sp,
    color: AppColors.textOnDark,
  );

  static final cardSubtitle = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.normal,
    fontSize: 14.sp,
    color: AppColors.textOnDark.withValues(alpha: 0.85),
  );
}
