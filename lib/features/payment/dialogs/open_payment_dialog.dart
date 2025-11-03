// open_payment_dialog.dart
import 'package:alrahma/core/models/payment_model.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:alrahma/features/payment/dialogs/no_available_projects.dart';
import 'package:alrahma/features/payment/dialogs/payment_dialog.dart';
import 'package:flutter/material.dart';

Future<void> openPaymentDialog(
  BuildContext context,
  PaymentModel initial,
  PaymentsCubit cubit, {
  bool isNew = false,
}) async {
  final screenWidth = MediaQuery.of(context).size.width;
  final fontSize = (screenWidth * 0.04).clamp(12.0, 18.0);

  // إعادة تحميل البيانات لضمان الحصول على أحدث القيم
  await cubit.loadPayments();

  final usedProjectIds = cubit.state.payments.map((p) => p.projectId).toSet();

  final availableProjects = isNew
      ? cubit.state.projects
            .where((p) => !usedProjectIds.contains(p.id))
            .toList()
      : cubit.state.projects
            .where(
              (p) =>
                  p.id == initial.projectId || !usedProjectIds.contains(p.id),
            )
            .toList();

  if (availableProjects.isEmpty) {
    noAvailableProjects(context);
    return;
  }

  String selectedProjectId = (initial.projectId.isEmpty)
      ? availableProjects.first.id
      : (availableProjects.any((p) => p.id == initial.projectId)
            ? initial.projectId
            : availableProjects.first.id);

  // تأكد إن النص اللي بتحطه في controllers هو رقم (string) فقط
  final totalCtrl = TextEditingController(
    text: initial.amountTotal.toStringAsFixed(2),
  );

  // لو فيه تاريخ - خذ آخر دفعة (amountPaid)، لو مفيش استخدم amountPaid من الموديل القديم أو صفر
  final paidInitialText = initial.history.isNotEmpty
      ? initial.history.last.amountPaid.toStringAsFixed(2)
      : (initial.amountPaid > 0
            ? initial.amountPaid.toStringAsFixed(2)
            : '0.00');

  final paidCtrl = TextEditingController(text: paidInitialText);

  DateTime date = initial.datePaid;
  final _formKey = GlobalKey<FormState>();

  await paymentDialog(
    isNew,
    context,
    screenWidth,
    _formKey,
    selectedProjectId,
    availableProjects,
    fontSize,
    totalCtrl,
    paidCtrl,
    date,
    initial,
    cubit,
  );
}
