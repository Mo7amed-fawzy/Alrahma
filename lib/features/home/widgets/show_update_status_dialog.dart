import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> showUpdateStatusDialog(BuildContext context) async {
  String status = "جارِ التحقق من التحديث...";
  Color color = AppColors.secondaryGolden;
  String title = "التحقق من التحديث";

  try {
    // 🔹 1) الحصول على بيانات التطبيق الحالية
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // 🔹 2) جلب آخر إصدار من Supabase
    final response = await Supabase.instance.client
        .from('updates')
        .select()
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response != null) {
      final latestVersion = response['version'];
      final apkUrl = response['apk_url'];

      if (latestVersion == currentVersion) {
        status = "التطبيق محدّث إلى آخر إصدار ($currentVersion)";
        color = AppColors.alrahmaSecondColor;
        title = "✅ محدّث";
      } else {
        status =
            "تحديث جديد متاح ($latestVersion)\n(الإصدار الحالي: $currentVersion)";
        color = AppColors.primaryBlue;
        title = "🆕 تحديث متاح";
      }
    } else {
      status = "لم يتم العثور على بيانات تحديث حالياً.";
      color = AppColors.darkGray;
      title = "⚠️ لا توجد تحديثات";
    }
  } catch (e) {
    status = "حدث خطأ أثناء التحقق من التحديث:\n$e";
    color = AppColors.errorRed;
    title = "❌ خطأ";
  }

  // 🔹 3) عرض الـ Dialog بتصميم احترافي
  if (context.mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.scaffoldBackground,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- Header ----------
              Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(14),
                child: Icon(Icons.system_update, color: color, size: 38),
              ),
              const SizedBox(height: 16),

              // ---------- Title ----------
              Text(
                title,
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: color,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),

              // ---------- Status Text ----------
              Text(
                status,
                textAlign: TextAlign.center,
                style: CustomTextStyles.cairoRegular16.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),

              // ---------- Action Button ----------
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("إغلاق", style: CustomTextStyles.buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
