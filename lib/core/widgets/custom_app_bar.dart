import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// حساب حجم نص العنوان لو عايز تستخدمه في AppBar badge مثلاً
// final double cardWidth = (width / (isTablet ? 2 : 1)) - (20.w * 1.5);
// final double textSize = (cardWidth * 0.12).clamp(14.sp, 22.sp);
AppBar customAppBar(text, backgroundColor, context) {
  final width = MediaQuery.of(context).size.width;

  final bool isTablet = width >= 800;
  final double cardWidth = (width / (isTablet ? 2 : 1)) - (20.w * 1.5);
  final double textSize = (cardWidth * 0.12).clamp(14.sp, 22.sp);

  return AppBar(
    title: Text(
      text,
      style: CustomTextStyles.cairoBold20.copyWith(fontSize: textSize * 0.9),
    ),
    backgroundColor: backgroundColor,
    centerTitle: true,
  );
}
