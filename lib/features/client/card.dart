import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/features/client/cubit/clients_cubit.dart';
import '../../core/models/client_model.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/custom_text_styles.dart';

/// تبني TextField عربي جاهز مع RTL
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  TextInputType? keyboardType, // إضافة اختيار نوع الكيبورد
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType, // يستخدم إذا تم تمريره
    textAlign: TextAlign.right,
    decoration: InputDecoration(
      labelText: label,
      alignLabelWithHint: true,
      labelStyle: TextStyle(color: Colors.black87, fontSize: 16.sp),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade400, width: 1.w),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 2.w),
      ),
    ),
  );
}

/// تبني Card لكل عميل
Widget buildClientCard({
  required ClientModel client,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  return GestureDetector(
    onTap: onEdit,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.w,
            backgroundColor: AppColors.primaryBlue,
            child: Text(
              client.name.isNotEmpty ? client.name[0] : '?',
              style: CustomTextStyles.cairoBold20.copyWith(
                color: Colors.white,
                fontSize: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: CustomTextStyles.cairoBold20.copyWith(fontSize: 18.sp),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${client.phone} • ${client.address}',
                  style: CustomTextStyles.cairoRegular16.copyWith(
                    color: Colors.grey[700],
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red, size: 24.sp),
            onPressed: onDelete,
          ),
        ],
      ),
    ),
  );
}

/// تبني Dialog لإضافة أو تعديل عميل
Future<void> showClientDialog({
  required BuildContext context,
  required ClientModel initial,
  required bool isNew,
  required Function(ClientModel updated) onSave,
}) {
  final nameCtrl = TextEditingController(text: initial.name);
  final phoneCtrl = TextEditingController(text: initial.phone);
  final addrCtrl = TextEditingController(text: initial.address);
  final _formKey = GlobalKey<FormState>();

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNew ? 'إضافة عميل' : 'تعديل العميل',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: 20.sp,
                ),
              ),
              SizedBox(height: 20.h),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameCtrl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'الاسم',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 16.sp,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2.w,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'الرجاء إدخال الاسم'
                          : null,
                    ),
                    SizedBox(height: 12.h),

                    TextFormField(
                      controller: phoneCtrl,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        labelText: 'الهاتف',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 16.sp,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2.w,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'الرجاء إدخال الهاتف'
                          : null,
                    ),
                    SizedBox(height: 12.h),

                    TextFormField(
                      controller: addrCtrl,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        labelText: 'العنوان',
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          color: Colors.black87,
                          fontSize: 16.sp,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Colors.grey.shade400,
                            width: 1.w,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: AppColors.primaryBlue,
                            width: 2.w,
                          ),
                        ),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'الرجاء إدخال العنوان'
                          : null,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 25.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      textStyle: TextStyle(fontSize: 16.sp),
                    ),
                    child: const Text('إلغاء'),
                  ),
                  SizedBox(width: 12.w),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final updated = ClientModel(
                          id: initial.id,
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          address: addrCtrl.text.trim(),
                        );
                        onSave(updated);

                        // await context.read<ClientsCubit>().saveSelectedClientId(
                        //   updated.id,
                        // );
                        //  await clientsCubit.repository
                        //       .saveSelectedClientId(client.id);
                        await context
                            .read<ClientsCubit>()
                            .repository
                            .saveSelectedClientId(updated.id);

                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      'حفظ',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
