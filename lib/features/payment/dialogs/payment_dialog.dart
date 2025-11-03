// payment_dialog.dart
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/payment_history.dart';
import 'package:alrahma/core/models/payment_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:alrahma/features/payment/widgets/remaining_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<dynamic> paymentDialog(
  bool isNew,
  BuildContext context,
  double screenWidth,
  GlobalKey<FormState> _formKey,
  String selectedProjectId,
  List<ProjectModel> availableProjects,
  double fontSize,
  TextEditingController totalCtrl,
  TextEditingController paidCtrl,
  DateTime date,
  PaymentModel initial,
  PaymentsCubit cubit,
) {
  // paidCtrl.text = "0.0";
  bool canEditTotal = isNew;
  final FocusNode totalFocus = FocusNode();
  PaymentHistory? selectedHistory;
  final ValueNotifier<bool> isDirty = ValueNotifier(false);

  // بيانات أصلية لمقارنة التغييرات
  final String _origProjectId = selectedProjectId;
  final String _origTotal = totalCtrl.text;
  final String _origPaid = paidCtrl.text;
  final DateTime _origDate = date;

  void checkDirty() {
    final bool sameProject = selectedProjectId == _origProjectId;
    final bool sameTotal = totalCtrl.text == _origTotal;
    final bool samePaid = paidCtrl.text == _origPaid;
    final bool sameDate = date == _origDate;
    isDirty.value = !(sameProject && sameTotal && samePaid && sameDate);
  }

  totalCtrl.addListener(checkDirty);
  paidCtrl.addListener(() {
    if (!isNew) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final enteredPaid = double.tryParse(paidCtrl.text) ?? 0;
        // final total = double.tryParse(totalCtrl.text) ?? 0;

        final remaining = cubit.calculateRemainingForProject(
          selectedProjectId,
          cubit.state.payments,
          // excludePaymentId: initial.id,
        );

        if (enteredPaid > remaining) {
          paidCtrl.text = remaining.toStringAsFixed(2);
          paidCtrl.selection = TextSelection.fromPosition(
            TextPosition(offset: paidCtrl.text.length),
          );
        }

        checkDirty();
      });
    } else {
      checkDirty();
    }
  });

  return showDialog(
    barrierDismissible: !isNew,
    context: context,
    builder: (_) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: AppColors.alrahmaSecondColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          child: BlocBuilder<PaymentsCubit, PaymentsState>(
            bloc: cubit,
            builder: (context, state) {
              final usedProjectIds = state.payments
                  .map((p) => p.projectId)
                  .toSet();

              final availableProjectsLocal = isNew
                  ? state.projects
                        .where((p) => !usedProjectIds.contains(p.id))
                        .toList()
                  : state.projects
                        .where(
                          (p) =>
                              p.id == initial.projectId ||
                              !usedProjectIds.contains(p.id),
                        )
                        .toList();

              String? dropdownValue =
                  availableProjectsLocal.any((p) => p.id == selectedProjectId)
                  ? selectedProjectId
                  : null;

              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // عنوان الدايالوج
                      Text(
                        isNew ? 'إضافة دفعة' : 'تعديل دفعة',
                        style: CustomTextStyles.cairoBold24.copyWith(
                          color: AppColors.alrahmaSecondColor,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Dropdown المشاريع
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: dropdownValue,
                        items: availableProjectsLocal.map((p) {
                          final clientName = state.clients
                              .firstWhere(
                                (c) => c.id == p.clientId,
                                orElse: () => ClientModel(
                                  id: '',
                                  name: 'غير معروف',
                                  phone: '',
                                  address: '',
                                ),
                              )
                              .name;
                          return DropdownMenuItem<String>(
                            value: p.id,
                            child: Text(
                              '${p.type} • $clientName',
                              style: TextStyle(fontSize: fontSize),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          selectedProjectId = v ?? '';
                          checkDirty();
                        },
                        decoration: InputDecoration(
                          labelText: 'المشروع',
                          labelStyle: TextStyle(
                            color: AppColors.alrahmaSecondColor,
                            fontSize: fontSize,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0,
                            horizontal: 12.0,
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.alrahmaSecondColor,
                            ),
                          ),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'اختر المشروع' : null,
                      ),
                      SizedBox(height: screenWidth * 0.03),

                      // المبلغ الإجمالي مع زر تعديل
                      StatefulBuilder(
                        builder: (context, setState) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: totalCtrl,
                                  focusNode: totalFocus,
                                  enabled: canEditTotal,
                                  decoration: InputDecoration(
                                    labelText: 'المبلغ الإجمالي',
                                    labelStyle: TextStyle(
                                      color: AppColors.alrahmaSecondColor,
                                      fontSize: screenWidth * 0.045,
                                    ),
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.alrahmaSecondColor,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    final totalPaid = cubit
                                        .calculatePaidForProject(
                                          initial.projectId,
                                          cubit.state.payments,
                                        );
                                    final total =
                                        double.tryParse(totalCtrl.text) ?? 0;
                                    final paid =
                                        totalPaid +
                                        (double.tryParse(paidCtrl.text) ?? 0);
                                    if (total <= 0) {
                                      return 'لا يمكن أن يكون المبلغ الإجمالي صفر أو أقل';
                                    }
                                    if (paid < 0) {
                                      return 'ادخل مبلغ صحيح للدفعة';
                                    }
                                    if (paid > total) {
                                      return 'الدفعة لا يمكن أن تكون أكبر من الإجمالي';
                                    }

                                    return null;
                                  },
                                ),
                              ),
                              if (!isNew) SizedBox(width: screenWidth * 0.02),
                              if (!isNew)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      if (!canEditTotal) {
                                        canEditTotal = true;
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              FocusScope.of(
                                                context,
                                              ).requestFocus(totalFocus);
                                            });
                                      } else {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          canEditTotal = false;
                                          FocusScope.of(context).unfocus();
                                        } else {
                                          canEditTotal = true;
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    canEditTotal ? 'حفظ' : 'تعديل',
                                    style: TextStyle(
                                      color: canEditTotal
                                          ? Colors.green
                                          : Colors.orange,
                                      fontSize: screenWidth * 0.04,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      SizedBox(height: screenWidth * 0.03),

                      // المدفوع مع زر X + أزرار زيادة/نقصان بالقيمة الثابتة
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: paidCtrl,
                        builder: (context, value, _) {
                          final hasText =
                              value.text.trim().isNotEmpty &&
                              (double.tryParse(value.text) ?? 0) != 0;

                          return Row(
                            children: [
                              // زرار -20 (أنيق ودائري)
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.red.withOpacity(0.1),
                                  shape: const CircleBorder(),
                                ),
                                icon: const Icon(
                                  Icons.remove,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  final current =
                                      double.tryParse(paidCtrl.text) ?? 0;
                                  final newValue = (current - 20).clamp(
                                    0,
                                    double.infinity,
                                  );
                                  paidCtrl.text = newValue.toStringAsFixed(0);
                                  paidCtrl
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(offset: paidCtrl.text.length),
                                  );
                                  checkDirty();
                                },
                              ),

                              // Expanded علشان الـ TextFormField ياخد الباقي من المساحة
                              Expanded(
                                child: TextFormField(
                                  controller: paidCtrl,
                                  decoration: InputDecoration(
                                    labelText: 'المدفوع (دفعة)',
                                    hintText: 'ادخل مبلغ',
                                    filled: true,
                                    fillColor: Colors.grey.shade100,
                                    labelStyle: TextStyle(
                                      color: AppColors.alrahmaSecondColor,
                                      fontSize: screenWidth * 0.043,
                                    ),
                                    prefixIcon: hasText
                                        ? IconButton(
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 20,
                                              color: Colors.grey,
                                            ),
                                            onPressed: () {
                                              paidCtrl.text = "0";
                                              paidCtrl.selection =
                                                  TextSelection.fromPosition(
                                                    TextPosition(
                                                      offset:
                                                          paidCtrl.text.length,
                                                    ),
                                                  );
                                              checkDirty();
                                              FocusScope.of(context).unfocus();
                                            },
                                          )
                                        : null,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.alrahmaSecondColor,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => checkDirty(),
                                  validator: (value) {
                                    final total =
                                        double.tryParse(totalCtrl.text) ?? 0;
                                    final paid =
                                        double.tryParse(value ?? '') ?? -1;

                                    if (paid < 0) return 'ادخل مبلغ صحيح';

                                    final currentPaidSum = cubit
                                        .calculatePaidForProject(
                                          selectedProjectId,
                                          cubit.state.payments,
                                        );
                                    final remaining =
                                        total -
                                        currentPaidSum +
                                        (isNew ? 0 : initial.amountPaid);

                                    if (paid > remaining) {
                                      return 'الدفعة لا يمكن أن تتجاوز المتبقي (${remaining.toStringAsFixed(2)})';
                                    }

                                    return null;
                                  },
                                ),
                              ),

                              // زرار +20 (أنيق ودائري)
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.green.withOpacity(
                                    0.1,
                                  ),
                                  shape: const CircleBorder(),
                                ),
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  final current =
                                      double.tryParse(paidCtrl.text) ?? 0;
                                  final newValue = current + 20;
                                  paidCtrl.text = newValue.toStringAsFixed(0);
                                  paidCtrl
                                      .selection = TextSelection.fromPosition(
                                    TextPosition(offset: paidCtrl.text.length),
                                  );
                                  checkDirty();
                                },
                              ),
                            ],
                          );
                        },
                      ),

                      SizedBox(height: screenWidth * 0.04),

                      // التاريخ وسجل التعديلات
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'التاريخ: ${date.toString().split(' ').first}',
                            style: TextStyle(
                              color: AppColors.alrahmaSecondColor,
                              fontSize: screenWidth * 0.043,
                            ),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 12),
                          RemainingCard(
                            totalCtrl: totalCtrl,
                            paidCtrl: paidCtrl,
                            projectId: selectedProjectId,
                            cubit: cubit,
                            screenWidth: screenWidth,
                          ),
                          if (initial.history.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                ':سجل التعديلات',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.alrahmaSecondColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: SizedBox(
                                width: screenWidth * 0.92,
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: StatefulBuilder(
                                        builder: (context, setState) {
                                          return DropdownButtonFormField<
                                            PaymentHistory
                                          >(
                                            isExpanded: true,
                                            value: selectedHistory,
                                            menuMaxHeight:
                                                MediaQuery.of(
                                                  context,
                                                ).size.height *
                                                0.5,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              hintText: 'اختر تعديل سابق',
                                            ),
                                            items: initial.history.map((h) {
                                              return DropdownMenuItem<
                                                PaymentHistory
                                              >(
                                                value: h,
                                                child: Text(
                                                  "${h.date.toString().split(' ').first} - ${h.amountPaid}/${h.amountTotal}",
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (h) => setState(
                                              () => selectedHistory = h,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.05),

                      // أزرار الإلغاء والحفظ
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: screenWidth * 0.043,
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.03),
                          ValueListenableBuilder<bool>(
                            valueListenable: isDirty,
                            builder: (context, dirty, _) {
                              return ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: dirty
                                      ? AppColors.alrahmaSecondColor
                                      : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.03,
                                    ),
                                  ),
                                ),
                                onPressed: dirty
                                    ? () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          final newTotal = double.parse(
                                            totalCtrl.text,
                                          );
                                          final newPaidField =
                                              double.tryParse(paidCtrl.text) ??
                                              0;

                                          if (isNew) {
                                            // تأكد إن selectedProjectId مملوء
                                            if (selectedProjectId
                                                .trim()
                                                .isEmpty) {
                                              SnackbarHelper.show(
                                                context,
                                                message:
                                                    "اختر مشروع صالح قبل الحفظ",
                                                backgroundColor: Colors.red,
                                              );
                                              return;
                                            }

                                            // لو initial.id فاضي نولّد id بسيط (timestamp) — آمن وبدون حزمة خارجية
                                            final newId =
                                                (initial.id.isNotEmpty)
                                                ? initial.id
                                                : DateTime.now()
                                                      .microsecondsSinceEpoch
                                                      .toString();

                                            final newPayment = PaymentModel(
                                              id: newId,
                                              projectId: selectedProjectId,
                                              amountTotal: newTotal,
                                              amountPaid: newPaidField,
                                              datePaid: date,
                                              history: newPaidField > 0
                                                  ? [
                                                      PaymentHistory(
                                                        date: DateTime.now(),
                                                        amountTotal: newTotal,
                                                        amountPaid:
                                                            newPaidField,
                                                      ),
                                                    ]
                                                  : [],
                                            );

                                            cubit.addPayment(
                                              newPayment,
                                              onError: (msg) {
                                                SnackbarHelper.show(
                                                  context,
                                                  message: msg,
                                                  backgroundColor: Colors.red,
                                                );
                                              },
                                            );
                                          } else {
                                            final updated = initial.copyWith(
                                              amountTotal: newTotal,
                                              amountPaid: newPaidField,
                                            );
                                            cubit.editPayment(updated);
                                          }

                                          paidCtrl.clear();

                                          SnackbarHelper.show(
                                            context,
                                            message: "تم حفظ الدفعة بنجاح",
                                            backgroundColor:
                                                AppColors.alrahmaSecondColor,
                                          );

                                          Navigator.of(
                                            context,
                                            rootNavigator: true,
                                          ).pop();
                                        }
                                      }
                                    : null,

                                child: Text(
                                  'حفظ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.045,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    },
  );
}
