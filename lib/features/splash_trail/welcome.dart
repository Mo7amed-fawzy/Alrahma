import 'dart:async';
import 'package:alrahma/core/services/download_and_install_service.dart';
import 'package:alrahma/core/services/trial_service_supabase.dart';
import 'package:alrahma/core/services/update_checker.dart';
import 'package:alrahma/core/services/update_service.dart';
import 'package:alrahma/features/splash_trail/widgets/show_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/core/utils/assets.dart';
import 'package:alrahma/features/splash_trail/widgets/show_trial_ended_dialog.dart';

class WelcomeMessage extends StatefulWidget {
  const WelcomeMessage({super.key});

  @override
  State<WelcomeMessage> createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<WelcomeMessage> {
  bool _dialogShown = false;
  final TrialServiceSupabase _onlineService = TrialServiceSupabase();

  // النسخة الحالية للتطبيق
  final String currentVersion = "1.0.0";

  // Timer للفحص الدوري
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _checkTrial();

    // بعد أول frame نتحقق من وجود تحديث جديد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateUI();
    });

    // ضبط Timer لفحص التحديث كل 6 ساعات (21600 ثانية)
    _updateTimer = Timer.periodic(
      const Duration(seconds: 21600),
      (_) => _checkForUpdateUI(),
    );
  }

  @override
  void dispose() {
    UpdateService.stopListening();
    UpdateChecker.stop();
    _updateTimer?.cancel();
    super.dispose();
  }

  // UI Handler لفحص التحديث وإظهار الـ Dialog
  Future<void> _checkForUpdateUI() async {
    final updateInfo = await UpdateChecker.fetchLatestUpdate();
    if (updateInfo == null) return;

    if (UpdateChecker.isUpdateAvailable(
      currentVersion,
      updateInfo.latestVersion,
    )) {
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: !updateInfo.forceUpdate,
          builder: (_) => UpdateDialog(
            title: "تحديث جديد متاح",
            message:
                "تم إصدار نسخة جديدة (${updateInfo.latestVersion}). هل ترغب في التحديث الآن؟",
            onConfirm: (progressCallback) async {
              final path = await UpdateInstaller.download(
                updateInfo.apkUrl,
                onReceiveProgress: (count, total) {
                  progressCallback(total > 0 ? count / total : 0.0);
                },
              );
              await UpdateInstaller.install(path);
            },
          ),
        );
      });
    }
  }

  // الاستماع لتحديثات من Supabase Realtime أو trigger
  void _listenForUpdates() {
    UpdateService.checkUpdates(
      onUpdate: (payload) async {
        if (!mounted) return;

        if (payload['action'] == 'update_available') {
          final apkUrl = payload['url'];

          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => UpdateDialog(
              title: "تحديث جديد",
              message: "يوجد تحديث جديد للتطبيق. هل تريد التثبيت؟",
              onConfirm: (progressCallback) async {
                final path = await UpdateInstaller.download(
                  apkUrl,
                  onReceiveProgress: (count, total) {
                    progressCallback(total > 0 ? count / total : 0.0);
                  },
                );
                await UpdateInstaller.install(path);
              },
            ),
          );
        }
      },
    );
  }

  // فحص الترايل
  Future<void> _checkTrial() async {
    try {
      final result = await _onlineService.checkOrStartTrial();
      _handleTrialResult(result);
    } catch (e) {
      debugPrint("❌ Trial check failed: $e");
      if (!_dialogShown) {
        _dialogShown = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showBlockDialog(context);
        });
      }
    }
  }

  void _handleTrialResult(Map<String, dynamic> result) {
    final status = result['status'] as String;
    if (!mounted) return;

    if (status == "blocked_global" && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBlockDialog(
          context,
          messageTitle: "إيقاف مؤقت للخدمة",
          message: " .تم إيقاف التطبيق للصيانه المؤقته ",
          mainIcon: Icons.warning_amber_rounded,
        );
      });
      return;
    }

    if (status == "blocked_device" && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showBlockDialog(
          context,
          message: "تم حظر هذا الجهاز من استخدام التطبيق.",
        );
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSize = screenWidth * 0.04;

    return Container(
      margin: EdgeInsets.only(bottom: baseSize * 0.8),
      padding: EdgeInsets.all(baseSize),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.95),
            AppColors.lightGray.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(baseSize * 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.4),
            blurRadius: baseSize * 1.2,
            spreadRadius: baseSize * 0.2,
            offset: Offset(0, baseSize * 0.4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            AppStyle.images.alRaham,
            height: screenHeight * 0.08,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                Icons.dashboard_customize,
                size: screenHeight * 0.06,
                color: Colors.white,
              );
            },
          ),
          SizedBox(width: baseSize),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا بك في الرحمة، تابع أداء عملك بسهولة!',
                  softWrap: true,
                  style: CustomTextStyles.cairoBold20.copyWith(
                    fontSize: baseSize * 1.2,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: baseSize * 0.3,
                        offset: Offset(baseSize * 0.1, baseSize * 0.1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: baseSize * 0.3),
                Text(
                  'انجز مهامك بسهولة!',
                  style: CustomTextStyles.cairoRegular14.copyWith(
                    color: Colors.white70,
                    fontSize: baseSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
