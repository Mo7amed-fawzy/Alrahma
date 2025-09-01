import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/custom_text_styles.dart';

class ProjectSelector extends StatelessWidget {
  final DrawingCanvasCubit cubit;
  final List<ProjectModel> projects;
  final String selectedProjectId;
  final bool isEditing; // جديد

  const ProjectSelector({
    super.key,
    required this.cubit,
    required this.projects,
    required this.selectedProjectId,
    this.isEditing = false,
  });

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.lightGray,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6.r,
                    offset: Offset(0, 3.h),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.warning,
                    color: AppColors.accentOrange,
                    size: 48.sp,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "لا يوجد مشاريع، أضف مشروع أولاً",
                    style: CustomTextStyles.cairoSemiBold16.copyWith(
                      fontSize: 16.sp,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      // إرسال حدث للـ Cubit لإضافة مشروع جديد
                    },
                    icon: Icon(Icons.add, size: 20.sp),
                    label: Text(
                      "إضافة مشروع جديد",
                      style: CustomTextStyles.buttonText.copyWith(
                        fontSize: 16.sp,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentOrange,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 14.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: DropdownButtonFormField<String>(
          value: selectedProjectId.isEmpty ? null : selectedProjectId,
          items: projects.map((p) {
            return DropdownMenuItem(
              value: p.id,
              child: Text(
                "${p.type} • ${p.clientName ?? 'عميل غير معروف'}",
                style: CustomTextStyles.cairoRegular16.copyWith(
                  fontSize: 16.sp,
                ),
              ),
            );
          }).toList(),
          // هنا تم تعديل onChanged بحيث يقفل الـ Dropdown لو isEditing = true
          onChanged: isEditing ? null : (v) => cubit.selectProject(v ?? ""),
          decoration: InputDecoration(
            labelText: "اختر المشروع",
            labelStyle: CustomTextStyles.cairoSemiBold16.copyWith(
              fontSize: 16.sp,
              color: AppColors.accentOrange,
            ),
            filled: true,
            fillColor: AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 16.w,
            ),
          ),
          dropdownColor: AppColors.lightGray,
          style: CustomTextStyles.cairoRegular16.copyWith(
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
          iconEnabledColor: AppColors.accentOrange,
        ),
      ),
    );
  }
}
