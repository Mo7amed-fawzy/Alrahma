import 'package:alrahma/core/utils/app_colors.dart';
import 'package:flutter/material.dart';

class AddPaymentButton extends StatelessWidget {
  final double screenWidth;
  final VoidCallback? onPressed; // هنمرر دالة من الخارج

  const AddPaymentButton({
    super.key,
    required this.screenWidth,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed, // استدعاء الدالة من الخارج
      backgroundColor: AppColors.alrahmaSecondColor,
      child: Icon(
        Icons.add,
        color: AppColors.lightGray,
        size: screenWidth * 0.08,
      ),
    );
  }
}
