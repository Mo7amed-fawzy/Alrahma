// lib/features/splash_trail/widgets/welcome_message.dart
import 'dart:async';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/features/splash_trail/widgets/show_update_dialog.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:alrahma/core/services/download_and_install_service.dart';
import 'package:alrahma/core/services/trial_service_supabase.dart';
import 'package:alrahma/core/services/update_checker.dart';
import 'package:alrahma/core/services/update_service.dart';
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
  String _currentVersion = "0.0.0";
  Timer? _updateTimer;
  SharedPreferences? _prefs;

  static const _kLastPromptedVersionKey = 'last_prompted_version';

  @override
  void initState() {
    super.initState();
    _initExtras();
    _checkTrial();
    _listenForUpdates();
  }

  Future<void> _initExtras() async {
    _prefs = await SharedPreferences.getInstance();
    // اقرأ نسخة التطبيق الفعلية
    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version; // مثل "1.0.5"
    } catch (e) {
      _currentVersion = "0.0.0";
    }

    // بعد أول frame نتحقق من وجود تحديث جديد
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateUI();
    });

    // ضبط Timer لفحص التحديث كل 6 ساعات
    _updateTimer = Timer.periodic(
      const Duration(hours: 6),
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

    // لو النسخة الحالية أصغر
    if (UpdateChecker.isUpdateAvailable(
      _currentVersion,
      updateInfo.latestVersion,
    )) {
      final lastPrompted = _prefs?.getString(_kLastPromptedVersionKey);
      // لو طلبنا نفس النسخة قبل كده متظهرش تاني
      if (lastPrompted == updateInfo.latestVersion) {
        debugPrint(
          "Update already prompted for version ${updateInfo.latestVersion}",
        );
        return;
      }

      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: !updateInfo.forceUpdate,
          builder: (_) => UpdateDialog(
            title: "تحديث جديد متاح",
            message:
                "تم إصدار نسخة جديدة (${updateInfo.latestVersion}). هل ترغب في التحديث الآن؟",
            onConfirm: (progressCb) async {
              // progressCb expects (double, {bool indeterminate})
              try {
                await UpdateInstaller.download(
                  updateInfo.apkUrl,
                  onReceiveProgress: (received, total) {
                    if (total <= 0) {
                      // indeterminate
                      progressCb(0.0, indeterminate: true);
                    } else {
                      final p = (received / total).clamp(0.0, 1.0);
                      progressCb(p, indeterminate: false);
                    }
                  },
                );
                // لو التحميل انتهى بنجاح، خزّن إننا عرضنا/نزلنا هذه النسخة
                await _prefs?.setString(
                  _kLastPromptedVersionKey,
                  updateInfo.latestVersion,
                );
                // وابدأ التثبيت (يفتح مثبت النظام)
                final path =
                    '${(await getApplicationDocumentsDirectory()).path}/update.apk';
                await UpdateInstaller.install(path);
              } catch (e) {
                // رمي خطأ ووِرِّيه للمستخدم عبر SnackBar (dialog ما يُغلق إلا بضغط المستخدم أو بعد نجاح)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطأ أثناء تحميل التحديث: $e')),
                );
                rethrow;
              }
            },
          ),
        );
      });
    } else {
      debugPrint("No update available. Current: $_currentVersion");
    }
  }

  // الاستماع لتحديثات من Supabase Realtime
  void _listenForUpdates() {
    UpdateService.checkUpdates(
      onUpdate: (payload) async {
        if (!mounted) return;
        // payload ممكن يجي Map أو JSON string — سوّيت المعالجة في UpdateService
        if (payload['action'] == 'update_available') {
          // مباشرة نفحص الجدول بدل الاعتماد على payload فقط
          await _checkForUpdateUI();
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
                  ),
                ),
                SizedBox(height: baseSize * 0.3),
                Text(
                  'انجز مهامك بسهولة!',
                  style: CustomTextStyles.cairoRegular14.copyWith(
                    color: AppColors.alrahmaSecondColor,
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
