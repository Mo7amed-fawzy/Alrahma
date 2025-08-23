import 'package:flutter/material.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'package:tabea/core/utils/custom_text_styles.dart';
import 'package:tabea/core/widgets/premium_loading_indicator.dart';

Widget buildPremiumLoader({
  String message = 'جاري تحميل البيانات...',
  TextStyle? messageTextStyle,
  Color color = AppColors.primaryBlue,
  double size = 60,
}) {
  return PremiumLoader(
    isLoading: true,
    message: message,
    messageTextStyle: messageTextStyle ?? CustomTextStyles.cairoRegular16,
    color: color,
    size: size,
    showGlowEffect: true,
    isUserInteractionEnabled: false,
  );
}
