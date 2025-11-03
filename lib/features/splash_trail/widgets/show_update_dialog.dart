// lib/features/splash_trail/widgets/update_dialog_ui.dart
import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

typedef OnConfirmCallback = Future<void> Function(void Function(double));

class UpdateDialog extends StatelessWidget {
  final String title;
  final String message;
  final OnConfirmCallback onConfirm;
  final IconData mainIcon;
  final Color iconColor;

  const UpdateDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.mainIcon = Icons.system_update_alt_rounded,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    double progress = 0.0;
    bool isDownloading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
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
                Icon(mainIcon, size: 60, color: iconColor),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: CustomTextStyles.cairoBold24.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 6,
                      ),
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
                if (isDownloading) ...[
                  LinearProgressIndicator(
                    value: progress,
                    color: Colors.white,
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: CustomTextStyles.cairoBold20.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
                if (!isDownloading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade300,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 28,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "لاحقاً",
                          style: CustomTextStyles.cairoBold20.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 28,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          setState(() => isDownloading = true);
                          await onConfirm((value) {
                            setState(() {
                              progress = value;
                            });
                          });
                          Navigator.pop(context);
                        },
                        child: Text(
                          "تحديث الآن",
                          style: CustomTextStyles.cairoBold20.copyWith(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
