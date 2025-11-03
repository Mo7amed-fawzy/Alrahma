import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/payment_history.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
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

  // -------------------- Load & Save --------------------
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

  Future<void> saveAllPayments() async {
    await paymentsPrefs.saveModels(
      CacheKeys.paymentsPrefsKey,
      state.payments,
      (p) => p.toJson(),
    );
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

    emit(state.copyWith(availableDates: uniqueDates));
  }

  // -------------------- Filters --------------------
  void filterPayments(String query) {
    final trimmed = query.trim().toLowerCase();
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

      return client.name.toLowerCase().contains(trimmed) ||
          client.phone.toLowerCase().contains(trimmed) ||
          project.type.toLowerCase().contains(trimmed) ||
          p.amountTotal.toString().contains(trimmed) ||
          p.amountPaid.toString().contains(trimmed) ||
          p.remainingAmount.toString().contains(trimmed) ||
          p.datePaid.toIso8601String().contains(trimmed);
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

  // -------------------- CRUD --------------------
  void addPayment(PaymentModel p, {required Function(String) onError}) async {
    // دفاعي: تأكد projectId موجود
    if (p.projectId.trim().isEmpty) {
      onError('اختر مشروع صالح قبل الحفظ');
      return;
    }

    final index = state.payments.indexWhere((e) => e.projectId == p.projectId);

    if (index != -1) {
      // المشروع موجود بالفعل → أضيف الدفعة الجديدة كـ history
      final existing = state.payments[index];

      // نضيف الدفعة للـ history
      final newHistory = List<PaymentHistory>.from(existing.history)
        ..add(
          PaymentHistory(
            date: DateTime.now(),
            amountTotal: p.amountTotal,
            amountPaid: p.amountPaid,
          ),
        );

      // نحافظ على amountPaid القديم (للتوافق)، لكن الحساب النهائي يعتمد على الـ history
      final updatedPayment = existing.copyWith(
        amountTotal: p.amountTotal,
        amountPaid: existing.amountPaid,
        history: newHistory,
      );

      final updated = List<PaymentModel>.from(state.payments)
        ..[index] = updatedPayment;

      emit(state.copyWith(payments: updated, filteredPayments: updated));
      await saveAllPayments();
      await saveDates();

      // debug
      final projectId = p.projectId;
      print('--- payments for project $projectId (after add existing) ---');
      for (var pay in state.payments.where((x) => x.projectId == projectId)) {
        final hist = pay.history.fold(0.0, (s, h) => s + h.amountPaid);
        print(
          'id:${pay.id} total:${pay.amountTotal} amountPaid:${pay.amountPaid} date:${pay.datePaid} historySum:$hist historyCount:${pay.history.length}',
        );
      }
      print(
        'calculated paid: ${calculatePaidForProject(projectId, state.payments)}',
      );
      print(
        'calculated remaining: ${calculateRemainingForProject(projectId, state.payments)}',
      );
    } else {
      // أول دفعة للمشروع → نعرّف history أولي (ونضبط amountPaid إلى 0 لتوضيح أن history هو المرجع)
      final firstHistory = p.amountPaid > 0
          ? <PaymentHistory>[
              PaymentHistory(
                date: DateTime.now(),
                amountTotal: p.amountTotal,
                amountPaid: p.amountPaid,
              ),
            ]
          : <PaymentHistory>[];

      // ننسخ الـ PaymentModel لكن نضع amountPaid = 0.0 لأننا نستخدم history كمصدر المدفوع
      final paymentWithHistory = p.copyWith(
        history: firstHistory,
        amountPaid: 0.0,
      );

      final updated = List<PaymentModel>.from(state.payments)
        ..add(paymentWithHistory);

      emit(state.copyWith(payments: updated, filteredPayments: updated));
      await saveAllPayments();
      await saveDates();

      // debug
      final projectId = p.projectId;
      print('--- payments for project $projectId (after add new) ---');
      for (var pay in state.payments.where((x) => x.projectId == projectId)) {
        final hist = pay.history.fold(0.0, (s, h) => s + h.amountPaid);
        print(
          'id:${pay.id} total:${pay.amountTotal} amountPaid:${pay.amountPaid} date:${pay.datePaid} historySum:$hist historyCount:${pay.history.length}',
        );
      }
      print(
        'calculated paid: ${calculatePaidForProject(projectId, state.payments)}',
      );
      print(
        'calculated remaining: ${calculateRemainingForProject(projectId, state.payments)}',
      );
    }
  }

  void editPayment(PaymentModel p) async {
    final updated = state.payments.map((e) {
      if (e.id == p.id) {
        // أول دفعة: لو history فاضي → سجلها في history وافرغ amountPaid (history هو المرجع)
        if (e.history.isEmpty) {
          final firstHistory = [
            PaymentHistory(
              date: DateTime.now(),
              amountTotal: p.amountTotal,
              amountPaid: p.amountPaid,
            ),
          ];

          return e.copyWith(
            amountTotal: p.amountTotal,
            amountPaid: 0.0,
            history: firstHistory,
          );
        }

        // باقي الحالات (مش أول دفعة)
        if (p.amountPaid <= 0) {
          // لو ما فيش دفعة جديدة (قيمة <= 0) يبقى نكتفي بتحديث الإجمالي أو القيمة بدون إضافة تاريخ
          return e.copyWith(
            amountTotal: p.amountTotal,
            amountPaid: e.amountPaid,
            history: e.history,
          );
        }

        // نحسب المتبقي بالنسبة للدفعة اللي دخلها المستخدم (الدفاعي — قبل إضافة history)
        final remaining =
            p.amountTotal -
            (p.amountPaid + e.history.fold(0.0, (s, h) => s + h.amountPaid));

        if (remaining <= 0) {
          // لو الدفعة تغطي أو تتجاوز المتبقي → نخزن التاريخ لكن نحتفظ بالـ history كما هو
          final newHistoryNoDup = List<PaymentHistory>.from(e.history)
            ..add(
              PaymentHistory(
                date: DateTime.now(),
                amountTotal: p.amountTotal,
                amountPaid: p.amountPaid,
              ),
            );

          return e.copyWith(
            amountTotal: p.amountTotal,
            amountPaid: 0.0,
            history: newHistoryNoDup,
          );
        }

        // إضافة دفعة عادية: نضيفها في history ونجعل amountPaid = 0.0
        final newHistory = List<PaymentHistory>.from(e.history)
          ..add(
            PaymentHistory(
              date: DateTime.now(),
              amountTotal: p.amountTotal,
              amountPaid: p.amountPaid,
            ),
          );

        return e.copyWith(
          amountTotal: p.amountTotal,
          amountPaid: 0.0,
          history: newHistory,
        );
      }
      return e;
    }).toList();

    emit(state.copyWith(payments: updated, filteredPayments: updated));
    await saveAllPayments();
    await saveDates();

    // ✅ debug بعد التعديل
    final projectId = p.projectId;
    print('--- payments for project $projectId (after edit) ---');
    for (var pay in state.payments.where((x) => x.projectId == projectId)) {
      final hist = pay.history.fold(0.0, (s, h) => s + h.amountPaid);
      print(
        'id:${pay.id} total:${pay.amountTotal} amountPaid:${pay.amountPaid} date:${pay.datePaid} historySum:$hist historyCount:${pay.history.length}',
      );
    }
    print(
      'calculated paid: ${calculatePaidForProject(projectId, state.payments)}',
    );
    print(
      'calculated remaining: ${calculateRemainingForProject(projectId, state.payments)}',
    );
  }

  void deletePayment(String id) async {
    final updated = state.payments.where((e) => e.id != id).toList();
    emit(state.copyWith(payments: updated, filteredPayments: updated));
    await saveAllPayments();
    await saveDates();
  }

  // -------------------- Calculations --------------------
  // حساب إجمالي المدفوع لمشروع معين
  double calculatePaidForProject(
    String projectId,
    List<PaymentModel> payments,
  ) {
    final projectPayments = payments
        .where((p) => p.projectId == projectId)
        .toList();
    if (projectPayments.isEmpty) return 0.0;

    // مجموع كل الـ history عبر كل السجلات
    final historySum = projectPayments.fold<double>(
      0.0,
      (sum, p) =>
          sum + p.history.fold<double>(0.0, (hSum, h) => hSum + h.amountPaid),
    );

    // حالات قديمة: لو السجل ما فيه history نأخذ amountPaid من السجل
    final amountPaidFromModels = projectPayments.fold<double>(
      0.0,
      (sum, p) => sum + (p.history.isEmpty ? p.amountPaid : 0.0),
    );

    return historySum + amountPaidFromModels;
  }

  // حساب المتبقي لمشروع معين
  double calculateRemainingForProject(
    String projectId,
    List<PaymentModel> payments,
  ) {
    final projectPayments = payments
        .where((p) => p.projectId == projectId)
        .toList();
    if (projectPayments.isEmpty) return 0.0;

    // نعيد السلوك القديم: ناخد أكبر قيمة amountTotal بين السجلات
    final total = projectPayments
        .map((p) => p.amountTotal)
        .reduce((a, b) => a > b ? a : b);

    final paidSum = calculatePaidForProject(projectId, payments);

    final remaining = total - paidSum;

    return remaining < 0 ? 0 : remaining;
  }

  // -------------------- Helpers for UI --------------------
  bool checkDirty({
    required String selectedProjectId,
    required String origProjectId,
    required String total,
    required String origTotal,
    required String paid,
    required String origPaid,
    required DateTime date,
    required DateTime origDate,
  }) {
    return !(selectedProjectId == origProjectId &&
        total == origTotal &&
        paid == origPaid &&
        date == origDate);
  }

  double clampPaidToRemaining({
    required String selectedProjectId,
    required List<PaymentModel> payments,
    required double enteredPaid,
  }) {
    final remaining = calculateRemainingForProject(selectedProjectId, payments);
    return enteredPaid > remaining ? remaining : enteredPaid;
  }
}
