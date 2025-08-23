// splash_state.dart
part of 'splash_cubit.dart';

abstract class SplashState {}

class SplashInitial extends SplashState {}

class SplashTrialActive extends SplashState {
  final int remainingDays;
  SplashTrialActive({required this.remainingDays});
}

class SplashTrialEnded extends SplashState {}
