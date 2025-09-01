// payments/cubit/payments_cubit.dart
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/cache/app_preferences.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/project_model.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final AppPreferences paymentsPrefs;
  final AppPreferences projectsPrefs;
  final AppPreferences clientsPrefs; // ✅ أضفنا clientsPrefs

  // static const String _paymentsKey = 'payments_list';
  // static const String _projectsKey = 'projects_list';
  // static const String _clientsKey = 'clients_list'; // لو في مفتاح للعملاء

  PaymentsCubit({
    required this.paymentsPrefs,
    required this.projectsPrefs,
    required this.clientsPrefs, // ✅
  }) : super(PaymentsState.initial()) {
    loadData();
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));

    // جلب البيانات
    final payments = await paymentsPrefs.getModels(
      CacheKeys.paymentsPrefsKey,
      (j) => PaymentModel.fromJson(j),
    );

    final projects = await projectsPrefs.getModels(
      CacheKeys.projectsKey,
      (j) => ProjectModel.fromJson(j),
    );

    final clients = await clientsPrefs.getModels(
      CacheKeys.clientsStorageKey,
      (j) => ClientModel.fromJson(j),
    );

    // ربط كل مشروع باسم العميل
    final projectsWithClientName = projects.map((project) {
      final client = clients.firstWhere(
        (c) => c.id == project.clientId,
        orElse: () =>
            ClientModel(id: '', name: 'غير معروف', phone: '', address: ''),
      );
      project.clientName = client.name; // ✅ اربط الاسم هنا
      return project;
    }).toList();

    emit(
      state.copyWith(
        isLoading: false,
        payments: payments,
        projects: projectsWithClientName,
        clients: clients, // ✅ ضيفنا clients للـ state
      ),
    );
  }

  Future<void> _saveAll() async {
    await paymentsPrefs.saveModels(
      CacheKeys.paymentsPrefsKey,
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
