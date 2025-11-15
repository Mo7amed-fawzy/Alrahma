import 'dart:async';
import 'package:alrahma/core/services/download_and_install_service.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alrahma/core/services/update_checker.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/core/utils/assets.dart';
import 'package:alrahma/features/splash_trail/widgets/show_update_dialog.dart';
import 'package:alrahma/features/splash_trail/widgets/show_trial_ended_dialog.dart';
import 'package:alrahma/core/services/trial_service_supabase.dart';
import 'package:alrahma/core/services/update_service.dart';

class WelcomeMessage extends StatefulWidget {
  const WelcomeMessage({super.key});

  @override
  State<WelcomeMessage> createState() => _WelcomeMessageState();
}

class _WelcomeMessageState extends State<WelcomeMessage>
    with WidgetsBindingObserver {
  bool _dialogShown = false;
  final TrialServiceSupabase _onlineService = TrialServiceSupabase();
  String _currentVersion = "0.0.0";
  Timer? _updateTimer;
  SharedPreferences? _prefs;

  static const _kLastPromptedVersionKey = 'last_prompted_version';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initExtras();
    _checkTrial();
    _listenForUpdates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    UpdateService.stopListening();
    UpdateChecker.stop();
    _updateTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkIfDownloadedUpdateInstalled();
    }
  }

  Future<void> _initExtras() async {
    _prefs = await SharedPreferences.getInstance();
    try {
      final info = await PackageInfo.fromPlatform();
      _currentVersion = info.version;
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForUpdateUI();
    });

    _updateTimer = Timer.periodic(
      const Duration(hours: 6),
      (_) => _checkForUpdateUI(),
    );
  }

  Future<void> _checkIfDownloadedUpdateInstalled() async {
    if (_prefs == null) return;

    final downloadedVersion = _prefs!.getString('downloaded_version');
    final apkPath = _prefs!.getString('downloaded_apk_path');
    final downloadState = _prefs!.getString('download_state');

    if (downloadedVersion != null && downloadState == 'downloaded') {
      try {
        final packageInfo = await PackageInfo.fromPlatform();
        if (packageInfo.version == downloadedVersion) {
          // ✅ التحديث تم تثبيته
          await _prefs!.remove('downloaded_version');
          await _prefs!.remove('downloaded_apk_path');
          await _prefs!.remove('download_state');

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ تم تثبيت التحديث بنجاح!'),
              backgroundColor: AppColors.alrahmaSecondColor,
            ),
          );
        } else if (apkPath != null) {
          // ⚠️ لم يتم التثبيت بعد
          if (!mounted) return;
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (_) => AlertDialog(
              title: Text("تثبيت التحديث"),
              content: Text(
                "تم تحميل التحديث ($downloadedVersion) بنجاح. اضغط لتثبيته الآن.",
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    try {
                      await UpdateInstaller.install(apkPath);
                      // بعد فتح المثبت، التطبيق عادة سيذهب للخلف — سيتم التحقق عند resume
                    } on PlatformException catch (e) {
                      if (e.code == 'INSTALL_PERMISSION_REQUIRED') {
                        // هنا ممكن تعرض dialog يطلب من المستخدم تفعيل السماح من مصدر غير معروف
                        // ثم يرجع ويحاول التثبيت ثانية
                        SnackbarHelper.show(
                          context,
                          message:
                              '⚠️ تحتاج للسماح بالتثبيت من مصادر غير معروفة.',
                        );
                      } else {
                        SnackbarHelper.show(
                          context,
                          message: '❌ فشل التثبيت: ${e.message}',
                        );
                      }
                    } catch (e) {
                      SnackbarHelper.show(
                        context,
                        message: '❌ فشل التثبيت: $e',
                      );
                    }
                  },
                  child: Text("تثبيت"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("إغلاق"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        debugPrint("Error checking installed version: $e");
      }
    }
  }

  Future<void> _checkForUpdateUI() async {
    final updateInfo = await UpdateChecker.fetchLatestUpdate();
    if (updateInfo == null) return;

    if (UpdateChecker.isUpdateAvailable(
      _currentVersion,
      updateInfo.latestVersion,
    )) {
      final lastPrompted = _prefs?.getString(_kLastPromptedVersionKey);
      if (lastPrompted == updateInfo.latestVersion) return;

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
              try {
                final filePath = await UpdateInstaller.download(
                  updateInfo.apkUrl,
                  onReceiveProgress: (received, total) {
                    if (total <= 0) {
                      progressCb(0.0, indeterminate: true);
                    } else {
                      final p = (received / total).clamp(0.0, 1.0);
                      progressCb(p, indeterminate: false);
                    }
                  },
                );

                await _prefs?.setString('downloaded_apk_path', filePath);
                await _prefs?.setString(
                  'downloaded_version',
                  updateInfo.latestVersion,
                );
                await _prefs?.setString('download_state', 'downloaded');

                await _prefs?.setString(
                  _kLastPromptedVersionKey,
                  updateInfo.latestVersion,
                );

                if (!mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (_) => AlertDialog(
                    title: Text("جاهز للتثبيت"),
                    content: Text(
                      "تم تحميل التحديث (${updateInfo.latestVersion}) بنجاح. اضغط لتثبيته.",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          try {
                            await UpdateInstaller.install(filePath);
                          } catch (e) {
                            SnackbarHelper.show(
                              context,
                              message: '❌ فشل التثبيت: $e',
                              backgroundColor: AppColors.errorRed,
                            );
                          }
                        },
                        child: Text("تثبيت"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text("إغلاق"),
                      ),
                    ],
                  ),
                );
              } catch (e) {
                SnackbarHelper.show(
                  context,
                  message: '❌ فشل تحميل التحديث: $e',
                  backgroundColor: AppColors.errorRed,
                );
              }
            },
          ),
        );
      });
    } else {
      SnackbarHelper.show(
        context,
        message: "✅ لا يوجد تحديث. النسخة الحالية $_currentVersion",
        backgroundColor: AppColors.alrahmaSecondColor,
      );
      debugPrint("✅ لا يوجد تحديث. النسخة الحالية $_currentVersion");
    }
  }

  void _listenForUpdates() {
    UpdateService.checkUpdates(
      onUpdate: (payload) async {
        if (!mounted) return;
        if (payload['action'] == 'update_available') {
          await _checkForUpdateUI();
        }
      },
    );
  }

  Future<void> _checkTrial() async {
    try {
      final result = await _onlineService.checkOrStartTrial();
      _handleTrialResult(result);
    } catch (e) {
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
          message: "تم إيقاف التطبيق مؤقتًا للصيانة.",
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
            AppColors.primaryBlue.withOpacity(0.95),
            AppColors.lightGray.withOpacity(0.85),
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
        children: [
          Image.asset(
            AppStyle.images.alRaham,
            height: screenHeight * 0.08,
            errorBuilder: (_, __, ___) => Icon(
              Icons.dashboard_customize,
              size: screenHeight * 0.06,
              color: Colors.white,
            ),
          ),
          SizedBox(width: baseSize),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحبًا بك في الرحمة، تابع أداء عملك بسهولة!',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    fontSize: baseSize * 1.2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: baseSize * 0.3),
                Text(
                  'أنجز مهامك بسهولة!',
                  style: CustomTextStyles.cairoRegular14.copyWith(
                    color: Colors.white54,
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
