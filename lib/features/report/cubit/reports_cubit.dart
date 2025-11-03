import 'package:alrahma/core/funcs/init_and_load_databases.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportsState {
  final int clientsCount;
  final int projectsCount;
  final int paymentsCount;
  final bool loading;

  ReportsState({
    required this.clientsCount,
    required this.projectsCount,
    required this.paymentsCount,
    this.loading = true,
  });

  ReportsState copyWith({
    int? clientsCount,
    int? projectsCount,
    int? paymentsCount,
    bool? loading,
  }) {
    return ReportsState(
      clientsCount: clientsCount ?? this.clientsCount,
      projectsCount: projectsCount ?? this.projectsCount,
      paymentsCount: paymentsCount ?? this.paymentsCount,
      loading: loading ?? this.loading,
    );
  }
}

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit()
    : super(ReportsState(clientsCount: 0, projectsCount: 0, paymentsCount: 0));

  Future<void> loadReports() async {
    emit(state.copyWith(loading: true));

    final clients = await DatabasesNames.clientsPrefs.getModels(
      CacheKeys.clientsStorageKey,
      (json) => json,
    );
    final projects = await DatabasesNames.projectsPrefs.getModels(
      CacheKeys.projectsKey,
      (json) => json,
    );
    final payments = await DatabasesNames.paymentsPrefs.getModels(
      CacheKeys.paymentsPrefsKey,
      (json) => json,
    );

    emit(
      state.copyWith(
        clientsCount: clients.length,
        projectsCount: projects.length,
        paymentsCount: payments.length,
        loading: false,
      ),
    );
  }
}
