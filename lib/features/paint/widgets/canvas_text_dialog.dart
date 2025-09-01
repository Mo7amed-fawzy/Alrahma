import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

Future<Map<String, dynamic>?> showAddTextDialog(BuildContext context) async {
  final TextEditingController controller = TextEditingController();
  bool addBackground = false;
  Color bgColor = Colors.white.withOpacity(0.7);
  double selectedFontSize = 20.sp; // responsive font

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.lightGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              "إضافة نص",
              style: CustomTextStyles.cairoBold20.copyWith(fontSize: 20.sp),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: CustomTextStyles.cairoRegular16.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: selectedFontSize,
                  ),
                  decoration: InputDecoration(
                    hintText: "أدخل النص هنا...",
                    hintStyle: CustomTextStyles.cairoLight14.copyWith(
                      fontSize: 14.sp,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 12.h,
                      horizontal: 16.w,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.mediumGray,
                        width: 1.w,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: AppColors.primaryBlue,
                        width: 2.w,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Slider حجم الخط
                Row(
                  children: [
                    Text(
                      "الحجم:",
                      style: CustomTextStyles.cairoRegular16.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        min: 12,
                        max: 60,
                        divisions: 12,
                        value: selectedFontSize,
                        onChanged: (v) {
                          setDialogState(() => selectedFontSize = v);
                        },
                      ),
                    ),
                    Text(
                      "${selectedFontSize.toInt()}",
                      style: CustomTextStyles.cairoRegular16.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Checkbox الخلفية
                Row(
                  children: [
                    Checkbox(
                      value: addBackground,
                      onChanged: (val) {
                        setDialogState(() => addBackground = val ?? false);
                      },
                    ),
                    Text(
                      "خلفية للنص",
                      style: CustomTextStyles.cairoRegular16.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.errorRed,
                ),
                child: Text(
                  "إلغاء",
                  style: CustomTextStyles.cairoSemiBold16.copyWith(
                    color: AppColors.errorRed,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (controller.text.trim().isNotEmpty) {
                    Navigator.pop(context, {
                      "text": controller.text.trim(),
                      "fontSize": selectedFontSize,
                      "hasBackground": addBackground,
                      "backgroundColor": addBackground ? bgColor : null,
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                child: Text(
                  "إضافة",
                  style: CustomTextStyles.buttonText.copyWith(fontSize: 16.sp),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
