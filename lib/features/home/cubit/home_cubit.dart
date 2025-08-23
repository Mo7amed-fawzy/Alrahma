import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/core/funcs/init_and_load_databases.dart';

class HomeState {
  final bool isLoading;
  HomeState({required this.isLoading});

  HomeState copyWith({bool? isLoading}) {
    return HomeState(isLoading: isLoading ?? this.isLoading);
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState(isLoading: true));

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 500)); // محاكاة تحميل
    await loadDatabases(); // الداتا الحقيقية
    emit(state.copyWith(isLoading: false));
  }
}
