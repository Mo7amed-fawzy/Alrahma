import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/material.dart';

Future<dynamic> noAvailableProjects(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;

  // ألوان أخف للعين
  final lightGreenBackground = AppColors.alrahmaSecondColor.withOpacity(0.08);
  final lightGreenIcon = AppColors.alrahmaSecondColor.withOpacity(0.9);

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.06,
        ),
        decoration: BoxDecoration(
          color: lightGreenBackground,
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة التنبيه مع خلفية دائرية أخف
            CircleAvatar(
              radius: screenWidth * 0.07,
              backgroundColor: AppColors.alrahmaSecondColor.withOpacity(0.15),
              child: Icon(
                Icons.info_outline,
                color: lightGreenIcon,
                size: screenWidth * 0.08,
              ),
            ),
            SizedBox(height: screenWidth * 0.03),

            // العنوان
            Text(
              'لا توجد مشاريع متاحة',
              style: CustomTextStyles.cairoBold24.copyWith(
                color: Colors.grey[700],
                fontSize: screenWidth * 0.048,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.015),

            // النص التوضيحي
            Text(
              'لا توجد مشاريع متبقية لإضافتها.',
              style: CustomTextStyles.cairoRegular16.copyWith(
                color: Colors.grey[700],
                fontSize: screenWidth * 0.043,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.035),

            // زر الإغلاق
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenWidth * 0.015,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.alrahmaSecondColor.withOpacity(
                    0.15,
                  ),
                ),
                child: Text(
                  'حسناً',
                  style: CustomTextStyles.cairoSemiBold16.copyWith(
                    color: AppColors.alrahmaSecondColor.withOpacity(0.9),
                    fontSize: screenWidth * 0.043,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
