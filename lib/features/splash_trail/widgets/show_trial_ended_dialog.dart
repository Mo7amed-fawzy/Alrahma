import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

import 'package:flutter/services.dart'; // لو عاوز تغلق التطبيق بعد الضغط

void showTrialEndedDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // يمنع الإغلاق بالضغط خارج الـ dialog
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.primaryBlue, // لون متوافق مع الهوم
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'انتهت الفترة المجانية',
              style: CustomTextStyles.cairoBold24.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              'لقد انتهت فترة التجربة للتطبيق.',
              textAlign: TextAlign.center,
              style: CustomTextStyles.cairoRegular16.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                SystemNavigator.pop(); // يغلق التطبيق نهائيًا
              },
              child: Text(
                'حسناً',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
