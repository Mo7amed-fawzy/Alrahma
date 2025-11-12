import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

typedef OnConfirmCallback = Future<void> Function(void Function(double));

class UpdateDialog extends StatefulWidget {
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
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double progress = 0.0;
  bool isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.mainIcon, size: 60, color: widget.iconColor),
            const SizedBox(height: 16),
            Text(
              widget.title,
              style: CustomTextStyles.cairoBold24.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              widget.message,
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
            ] else
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
                    ),
                    onPressed: () async {
                      setState(() => isDownloading = true);
                      try {
                        await widget.onConfirm((value) {
                          setState(() => progress = value);
                        });
                      } catch (e) {
                        // ممكن تعرض خطأ
                        debugPrint("Download/install failed: $e");
                      } finally {
                        if (mounted) Navigator.pop(context);
                      }
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
  }
}
