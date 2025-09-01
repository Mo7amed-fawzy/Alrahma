import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmDeleteDialog(
  BuildContext context, {
  String? itemName,
}) {
  final screenWidth = MediaQuery.of(context).size.width;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl, // 🌟 يخلي كل النصوص من اليمين لليسار
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
        title: Text(
          'تأكيد الحذف',
          style: CustomTextStyles.cairoBold24.copyWith(color: Colors.red),
        ),
        content: Text(
          itemName != null
              ? 'هل أنت متأكد من حذف "$itemName" نهائيًا؟'
              : 'هل أنت متأكد من الحذف نهائيًا؟',
          style: CustomTextStyles.cairoRegular18,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'إلغاء',
              style: CustomTextStyles.cairoSemiBold16.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: CustomTextStyles.cairoSemiBold16.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
