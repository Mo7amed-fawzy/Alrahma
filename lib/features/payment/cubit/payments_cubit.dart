// payments/cubit/payments_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/cache/app_preferences.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/project_model.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final AppPreferences paymentsPrefs;
  final AppPreferences projectsPrefs;

  static const String _paymentsKey = 'payments_list';
  static const String _projectsKey = 'projects_list';

  PaymentsCubit({required this.paymentsPrefs, required this.projectsPrefs})
    : super(PaymentsState.initial()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));

    final payments = await paymentsPrefs.getModels(
      _paymentsKey,
      (j) => PaymentModel.fromJson(j),
    );
    final projects = await projectsPrefs.getModels(
      _projectsKey,
      (j) => ProjectModel.fromJson(j),
    );

    emit(
      state.copyWith(isLoading: false, payments: payments, projects: projects),
    );
  }

  Future<void> _saveAll() async {
    await paymentsPrefs.saveModels(
      _paymentsKey,
      state.payments,
      (p) => p.toJson(),
    );
  }

  void addPayment(PaymentModel p) async {
    final updated = List<PaymentModel>.from(state.payments)..add(p);
    emit(state.copyWith(payments: updated));
    await _saveAll();
  }

  void editPayment(PaymentModel p) async {
    final updated = state.payments.map((e) => e.id == p.id ? p : e).toList();
    emit(state.copyWith(payments: updated));
    await _saveAll();
  }

  void deletePayment(String id) async {
    final updated = state.payments.where((e) => e.id != id).toList();
    emit(state.copyWith(payments: updated));
    await _saveAll();
  }
}
