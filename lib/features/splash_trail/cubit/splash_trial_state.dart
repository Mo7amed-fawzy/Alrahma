// splash_trial_state.dart
part of 'splash_trial_cubit.dart';

abstract class SplashTrialState {}

class SplashTrialInitial extends SplashTrialState {}

class SplashTrialActive extends SplashTrialState {
  final int remainingDays;
  SplashTrialActive({required this.remainingDays});
}

class SplashTrialEnded extends SplashTrialState {}
