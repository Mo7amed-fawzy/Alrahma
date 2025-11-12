// lib/features/splash_trail/widgets/update_dialog.dart
import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

typedef OnConfirmCallback =
    Future<void> Function(void Function(double, {bool indeterminate}));

class UpdateDialog extends StatefulWidget {
  final String title;
  final String message;
  final OnConfirmCallback onConfirm;
  final IconData mainIcon;
  final Color iconColor;
  final bool barrierDismissible;

  const UpdateDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.mainIcon = Icons.system_update_alt_rounded,
    this.iconColor = Colors.white,
    this.barrierDismissible = true,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double progress = 0.0;
  bool isDownloading = false;
  bool indeterminate = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.mainIcon, size: 56, color: widget.iconColor),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: CustomTextStyles.cairoBold24.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: CustomTextStyles.cairoRegular16.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            if (isDownloading) ...[
              if (indeterminate) ...[
                const SizedBox(height: 12),
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(
                  "جارٍ التحميل...",
                  style: CustomTextStyles.cairoRegular14.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ] else ...[
                LinearProgressIndicator(
                  value: progress,
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
            ],
            if (!isDownloading)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: AppColors.primaryBlue,
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
                    ),
                    onPressed: () async {
                      setState(() {
                        isDownloading = true;
                        indeterminate = false;
                        progress = 0.0;
                      });
                      try {
                        await widget.onConfirm((
                          received, {
                          bool indeterminate = false,
                        }) {
                          // received: either fraction (0..1) or ignored when indeterminate
                          if (indeterminate) {
                            setState(() {
                              this.indeterminate = true;
                            });
                          } else {
                            setState(() {
                              this.progress = received;
                              this.indeterminate = false;
                            });
                          }
                        });
                      } catch (e) {
                        // show error then allow user to retry/close
                        setState(() {
                          isDownloading = false;
                          indeterminate = false;
                          progress = 0.0;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("خطأ أثناء التحميل: $e")),
                        );
                        return;
                      }
                      // بعد انتهاء التحميل نغلق الديالوج (المثبت سيبدأ)
                      if (mounted) Navigator.pop(context);
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
