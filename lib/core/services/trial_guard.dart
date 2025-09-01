import 'package:flutter/material.dart';
import 'package:alrahma/core/services/trial_service.dart';
import 'package:alrahma/features/splash_trail/widgets/show_trial_ended_dialog.dart';

class TrialChecker {
  final TrialService _trialService = TrialService();

  TrialChecker();

  /// ✅ Check trial anywhere (Stateful or Stateless)
  Future<bool> checkTrial(BuildContext context) async {
    // init لو مش معمول
    if (!_trialService.isInitialized) {
      await _trialService.init();
    }

    final expired = await _trialService.isTrialExpired();

    if (expired && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showTrialEndedDialog(context);
      });
      return false;
    }

    return true;
  }
}
