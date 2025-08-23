import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/models/payment_model.dart';
import '../../core/models/project_model.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/custom_text_styles.dart';
import 'cubit/payments_cubit.dart';

class PaymentsPageContent extends StatelessWidget {
  const PaymentsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentsCubit>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('الدفعات', style: CustomTextStyles.cairoBold20),
          backgroundColor: AppColors.successGreen,
          centerTitle: true,
        ),
        body: BlocBuilder<PaymentsCubit, PaymentsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.payments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد دفعات بعد',
                      style: CustomTextStyles.cairoRegular18,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.payments.length,
              itemBuilder: (context, index) {
                final payment = state.payments[index];
                final project = state.projects.firstWhere(
                  (proj) => proj.id == payment.projectId,
                  orElse: () => ProjectModel(
                    id: '',
                    clientId: '',
                    type: 'غير معروف',
                    description: '',
                    createdAt: DateTime.now(),
                  ),
                );

                return GestureDetector(
                  onTap: () => _openPaymentDialog(context, payment, cubit),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successGreen.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.successGreen,
                          child: Text(
                            project.type.isNotEmpty ? project.type[0] : '?',
                            style: CustomTextStyles.cairoBold20.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${project.type} • ${project.createdAt.toString().split(' ').first}',
                                style: CustomTextStyles.cairoBold20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ${payment.amountTotal.toStringAsFixed(2)} • Paid: ${payment.amountPaid.toStringAsFixed(2)} • Remaining: ${payment.remainingAmount.toStringAsFixed(2)}',
                                style: CustomTextStyles.cairoRegular16.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () => cubit.deletePayment(payment.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final id = DateTime.now().millisecondsSinceEpoch.toString();
            _openPaymentDialog(
              context,
              PaymentModel(
                id: id,
                projectId: cubit.state.projects.isNotEmpty
                    ? cubit.state.projects.first.id
                    : '',
                amountTotal: 0,
                amountPaid: 0,
                datePaid: DateTime.now(),
              ),
              cubit,
              isNew: true,
            );
          },
          backgroundColor: AppColors.successGreen,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _openPaymentDialog(
    BuildContext context,
    PaymentModel initial,
    PaymentsCubit cubit, {
    bool isNew = false,
  }) {
    String selectedProjectId = initial.projectId;
    final totalCtrl = TextEditingController(
      text: initial.amountTotal.toString(),
    );
    final paidCtrl = TextEditingController(text: initial.amountPaid.toString());
    DateTime date = initial.datePaid;

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isNew ? 'إضافة دفعة' : 'تعديل دفعة',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    color: AppColors.successGreen,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value:
                      selectedProjectId.isEmpty &&
                          cubit.state.projects.isNotEmpty
                      ? cubit.state.projects.first.id
                      : selectedProjectId,
                  items: cubit.state.projects
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.id,
                          child: Text(
                            '${p.type} (${p.id.substring(p.id.length - 4)})',
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => selectedProjectId = v ?? '',
                  decoration: InputDecoration(
                    labelText: 'المشروع',
                    labelStyle: TextStyle(color: AppColors.successGreen),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.successGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalCtrl,
                  decoration: InputDecoration(
                    labelText: 'المبلغ الإجمالي',
                    labelStyle: TextStyle(color: AppColors.successGreen),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.successGreen),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: paidCtrl,
                  decoration: InputDecoration(
                    labelText: 'المدفوع (دفعة)',
                    labelStyle: TextStyle(color: AppColors.successGreen),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.successGreen),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'التاريخ: ${date.toString().split(' ').first}',
                      style: TextStyle(color: AppColors.successGreen),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          initialDate: date,
                          builder: (context, child) => Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: AppColors.successGreen,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null) date = picked;
                      },
                      child: Text(
                        'اختر التاريخ',
                        style: TextStyle(color: AppColors.successGreen),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('إلغاء', style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final updated = PaymentModel(
                          id: initial.id,
                          projectId: selectedProjectId,
                          amountTotal: double.tryParse(totalCtrl.text) ?? 0,
                          amountPaid: double.tryParse(paidCtrl.text) ?? 0,
                          datePaid: date,
                        );
                        if (isNew) {
                          cubit.addPayment(updated);
                        } else {
                          cubit.editPayment(updated);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'حفظ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
