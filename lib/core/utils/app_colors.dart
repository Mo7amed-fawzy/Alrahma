import 'package:flutter/material.dart';

abstract class AppColors {
  // ---------- Primary Colors ----------
  static const Color primaryBlue = Color(0xFF1E88E5); // أزرق هادئ
  static const Color secondaryGolden = Color(0xFFFFA000); // ذهبي / برتقالي فاتح
  static const Color accentOrange = Color(
    0xFFFF7043,
  ); // برتقالي إضافي إذا احتجت

  // ---------- Success / Warning / Error ----------
  static const Color successGreen = Color(
    0xFF43A047,
  ); // للمدفوعات أو الحالة الجيدة
  static const Color warningYellow = Color(0xFFFFEB3B); // تحذيرات بسيطة
  static const Color errorRed = Color(0xFFE53935); // أخطاء أو متأخرات

  // ---------- Secondary Colors ----------
  static const Color lightGray = Color(0xFFF5F5F5); // خلفيات ثانوية
  static const Color darkGray = Color(0xFF616161); // نصوص ثانوية
  static const Color mediumGray = Color(0xFF9E9E9E); // عناصر ثانوية

  // ---------- Text Colors ----------
  static const Color textPrimary = Color(0xFF212121); // نص أساسي
  static const Color textSecondary = Color(0xFF757575); // نص ثانوي
  static const Color textOnDark = Colors.white; // نص على كروت ملونة

  // ---------- Backgrounds ----------
  static const Color scaffoldBackground = Color(
    0xFFF2F2F2,
  ); // خلفية عامة للتطبيق
}
