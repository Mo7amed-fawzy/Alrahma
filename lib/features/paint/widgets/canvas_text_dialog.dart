import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

Future<Map<String, dynamic>?> showAddTextDialog(
  BuildContext context, {
  String? initialText,
  double? initialFontSize,
  bool? initialHasBackground,
  Color? initialBackgroundColor,
  bool isEditing = false,
}) async {
  final TextEditingController controller = TextEditingController(
    text: initialText ?? '',
  );
  bool addBackground = initialHasBackground ?? false;
  Color bgColor = initialBackgroundColor ?? Colors.white.withOpacity(0.7);
  double selectedFontSize = (initialFontSize != null)
      ? initialFontSize.clamp(12, 60)
      : 20.0;
  // responsive font

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            elevation: 6,
            backgroundColor: AppColors.lightGray,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            title: Text(
              isEditing ? "تعديل نص" : "إضافة نص",
              style: CustomTextStyles.cairoBold20.copyWith(
                fontSize: 20.sp,
                color: AppColors.alrahmaprimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            titlePadding: EdgeInsets.symmetric(vertical: 12.h),
            content: Scrollbar(
              radius: Radius.circular(8.r),
              thumbVisibility: true,
              thickness: 4.w,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Divider(
                      color: AppColors.mediumGray.withOpacity(0.3),
                      thickness: 1,
                    ),
                    SizedBox(height: 10.h),
                    TextField(
                      controller: controller,
                      autofocus: true,
                      style: CustomTextStyles.cairoRegular16.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: selectedFontSize,
                      ),
                      maxLines: null,
                      minLines: 3,
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

                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Text("الحجم:", style: CustomTextStyles.cairoSemiBold16),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppColors.primaryBlue,
                              inactiveTrackColor: AppColors.primaryBlue
                                  .withOpacity(0.3),
                              thumbColor: AppColors.secondaryGolden,
                              overlayColor: AppColors.secondaryGolden
                                  .withOpacity(0.2),
                            ),
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
                        ),
                        Text(
                          "${selectedFontSize.toInt()}",
                          style: CustomTextStyles.cairoRegular16,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        Checkbox(
                          value: addBackground,
                          activeColor: AppColors.primaryBlue,
                          onChanged: (val) {
                            setDialogState(() => addBackground = val ?? false);
                          },
                        ),
                        Text(
                          "إضافة خلفية للنص",
                          style: CustomTextStyles.cairoRegular16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.spaceBetween,
            actionsPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 10.h,
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
                  backgroundColor: AppColors.alrahmaprimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                child: Text(
                  isEditing ? "حفظ" : "إضافة",
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
