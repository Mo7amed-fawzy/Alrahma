// payments/cubit/payments_cubit.dart
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/payment_history.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/cache/app_preferences.dart';
import '../../../core/models/payment_model.dart';
import '../../../core/models/project_model.dart';

part 'payments_state.dart';

class PaymentsCubit extends Cubit<PaymentsState> {
  final AppPreferences paymentsPrefs;
  final AppPreferences projectsPrefs;
  final AppPreferences clientsPrefs;

  PaymentsCubit({
    required this.paymentsPrefs,
    required this.projectsPrefs,
    required this.clientsPrefs,
  }) : super(PaymentsState.initial()) {
    loadPayments();
  }

  Future<void> loadPayments() async {
    emit(state.copyWith(isLoading: true));
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

    debugPrint(
      'loadPayments -> payments: ${payments.length}, projects: ${projects.length}, clients: ${clients.length}',
    );
    debugPrint('projects ids: ${projects.map((p) => p.id).toList()}');
    debugPrint('clients ids: ${clients.map((c) => c.id).toList()}');

    emit(
      state.copyWith(
        isLoading: false,
        payments: payments,
        projects: projects,
        clients: clients,
        filteredPayments: payments,
      ),
    );

    await saveDates();
  }

  void filterPayments(String query) {
    final trimmed = query.trim().toLowerCase(); // نشيل مسافات أول/آخر النص

    if (trimmed.isEmpty) {
      emit(state.copyWith(filteredPayments: state.payments));
      return;
    }

    final filtered = state.payments.where((p) {
      final project = state.projects.firstWhere(
        (pr) => pr.id == p.projectId,
        orElse: () => ProjectModel(
          id: '',
          clientId: '',
          type: 'غير معروف',
          description: '',
          createdAt: DateTime.now(),
        ),
      );

      final client = state.clients.firstWhere(
        (c) => c.id == project.clientId,
        orElse: () =>
            ClientModel(id: '', name: 'غير معروف', phone: '', address: ''),
      );

      // تحقق من كل الحقول اللي عايزين نبحث فيها
      return client.name.toLowerCase().contains(trimmed) ||
          client.phone.toLowerCase().contains(trimmed) ||
          project.type.toLowerCase().contains(trimmed) ||
          p.amountTotal.toString().toLowerCase().contains(trimmed) ||
          p.amountPaid.toString().toLowerCase().contains(trimmed) ||
          p.remainingAmount.toString().toLowerCase().contains(trimmed) ||
          p.datePaid.toIso8601String().toLowerCase().contains(trimmed);
    }).toList();

    emit(state.copyWith(filteredPayments: filtered));
  }

  void filterByDate(DateTime? date) {
    if (date == null) {
      emit(state.copyWith(filteredPayments: state.payments));
      return;
    }

    final filtered = state.payments.where((p) {
      return p.datePaid.year == date.year &&
          p.datePaid.month == date.month &&
          p.datePaid.day == date.day;
    }).toList();

    emit(state.copyWith(filteredPayments: filtered));
  }

  Future<void> saveAllPayments() async {
    await paymentsPrefs.saveModels(
      CacheKeys.paymentsPrefsKey,
      state.payments,
      (p) => p.toJson(),
    );
  }

  void addPayment(PaymentModel p, {required Function(String) onError}) async {
    final project = state.projects.firstWhere(
      (pr) => pr.id == p.projectId,
      orElse: () => ProjectModel(
        id: '',
        clientId: '',
        type: '',
        description: '',
        createdAt: DateTime.now(),
      ),
    );

    final exists = state.payments.any((payment) {
      final proj = state.projects.firstWhere(
        (pr) => pr.id == payment.projectId,
        orElse: () => ProjectModel(
          id: '',
          clientId: '',
          type: '',
          description: '',
          createdAt: DateTime.now(),
        ),
      );
      return proj.clientId == project.clientId && proj.id == project.id;
    });

    if (exists) {
      onError('هذا المشروع تم إضافته للعميل مسبقًا');
      return;
    }

    final updated = List<PaymentModel>.from(state.payments)..add(p);
    emit(state.copyWith(payments: updated, filteredPayments: updated));
    await saveAllPayments();
    await saveDates();
  }

  void editPayment(PaymentModel p) async {
    final updated = state.payments.map((e) {
      if (e.id == p.id) {
        final newHistory = List<PaymentHistory>.from(e.history)
          ..add(
            PaymentHistory(
              date: DateTime.now(),
              amountTotal: e.amountTotal,
              amountPaid: e.amountPaid,
            ),
          );
        return p.copyWith(history: newHistory);
      }
      return e;
    }).toList();

    emit(state.copyWith(payments: updated, filteredPayments: updated));
    await saveAllPayments();
    await saveDates();
  }

  void deletePayment(String id) async {
    final updated = state.payments.where((e) => e.id != id).toList();
    emit(state.copyWith(payments: updated, filteredPayments: updated));
    await saveAllPayments();
    await saveDates();
  }

  Future<void> saveDates() async {
    final uniqueDates =
        state.payments
            .map(
              (p) =>
                  DateTime(p.datePaid.year, p.datePaid.month, p.datePaid.day),
            )
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    final dateStrings = uniqueDates.map((d) => d.toIso8601String()).toList();

    await paymentsPrefs.setData(CacheKeys.datesPrefsKey, dateStrings);

    // ✅ نحدّث الـ state بعد التخزين
    emit(state.copyWith(availableDates: uniqueDates));
  }

  double calculatePaidForProject(
    String projectId,
    List<PaymentModel> payments,
  ) {
    return payments.where((p) => p.projectId == projectId).fold<double>(0, (
      sum,
      p,
    ) {
      // 🟢 نجمع كل المدفوعات من الـ history
      final historySum = p.history.fold<double>(
        0,
        (hSum, h) => hSum + h.amountPaid,
      );
      return sum + historySum + p.amountPaid;
    });
  }

  double calculateRemainingForProject(
    String projectId,
    List<PaymentModel> payments,
  ) {
    final projectPayments = payments.where((p) => p.projectId == projectId);

    if (projectPayments.isEmpty) return 0;

    // إجمالي المشروع = أكبر قيمة بين amountTotal لكل الدفعات
    final total = projectPayments
        .map((p) => p.amountTotal)
        .reduce((a, b) => a > b ? a : b);

    final paidSum = calculatePaidForProject(projectId, payments);

    final remaining = total - paidSum;
    return remaining < 0 ? 0 : remaining;
  }
}
