// splash_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:tabea/core/funcs/init_and_load_databases.dart';

part 'splash_state.dart';

class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(SplashInitial());

  Future<void> checkTrial() async {
    final prefs = DatabasesNames.clientsPrefs;

    dynamic firstLaunchData = await prefs.getData('firstLaunchDate');
    DateTime firstLaunch;

    if (firstLaunchData == null) {
      firstLaunch = DateTime.now().toUtc();
      await prefs.setData('firstLaunchDate', firstLaunch.toIso8601String());
    } else {
      firstLaunch = DateTime.parse(firstLaunchData.toString());
    }

    final now = DateTime.now().toUtc();
    final difference = now.difference(firstLaunch).inDays;
    final remainingDays = 7 - difference;

    if (remainingDays <= 0) {
      emit(SplashTrialEnded());
    } else {
      emit(SplashTrialActive(remainingDays: remainingDays));
    }
  }
}
