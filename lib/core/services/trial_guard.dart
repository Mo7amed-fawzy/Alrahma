import 'package:flutter/material.dart';
import 'package:alrahma/core/services/trial_service.dart';
import 'package:alrahma/features/splash_trail/widgets/show_trial_ended_dialog.dart';

class TrialChecker {
  final TrialService _trialService = TrialService();

  TrialChecker();

  /// ✅ Check trial anywhere (Stateful or Stateless)
  Future<bool> checkTrial(BuildContext context) async {
    if (!_trialService.isInitialized) {
      await _trialService.init();
    }

    // validate integrity & device binding
    await _trialService.validateIntegrity();

    final expired = await _trialService.isTrialExpired();
    final remaining = await _trialService.remainingDays();

    if (expired && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTrialEndedDialog(context);
      });
      return false;
    }

    debugPrint("Trial active, $remaining days remaining ✅");
    return true;
  }
}
