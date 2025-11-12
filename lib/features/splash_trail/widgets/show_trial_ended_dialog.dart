import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/services.dart';

void showBlockDialog(
  BuildContext context, {
  String message = "تم حظر هذا الجهاز من استخدام التطبيق.",
  String messageTitle = "تم إيقاف الخدمة",
  IconData mainIcon = Icons.block,
  Color iconColor = Colors.white, // ✅ لون الأيقونة قابل للتغيير
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PopScope(
      canPop: false, // يمنع أي محاولة للخروج بالزر الخلفي
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mainIcon,
                size: 60,
                color: iconColor, // ✅ استخدم اللون اللي هييجي
              ),

              const SizedBox(height: 16),

              Text(
                messageTitle,
                style: CustomTextStyles.cairoBold24.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 6),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                message,
                style: CustomTextStyles.cairoRegular16.copyWith(
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 22),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 38,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  "حسناً",
                  style: CustomTextStyles.cairoBold20.copyWith(
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
