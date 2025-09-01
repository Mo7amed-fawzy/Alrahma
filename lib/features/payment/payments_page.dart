import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/widgets/show_confirm_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

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
                      size: screenWidth * 0.2,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: screenWidth * 0.04),
                    Text(
                      'لا توجد دفعات بعد',
                      style: CustomTextStyles.cairoRegular18.copyWith(
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.03,
              ),
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

                // جلب العميل المرتبط بالمشروع
                final client = state.clients.firstWhere(
                  (c) => c.id == project.clientId,
                  orElse: () => ClientModel(
                    id: '',
                    name: 'غير معروف',
                    phone: '',
                    address: '',
                  ),
                );

                return GestureDetector(
                  onTap: () => _openPaymentDialog(context, payment, cubit),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: EdgeInsets.symmetric(
                      vertical: screenWidth * 0.02,
                      horizontal: screenWidth * 0.01,
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.successGreen.withValues(alpha: 0.2),
                          blurRadius: screenWidth * 0.02,
                          offset: Offset(0, screenWidth * 0.01),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: screenWidth * 0.15,
                          height: screenWidth * 0.15,
                          child: CircleAvatar(
                            backgroundColor: AppColors.successGreen,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                project.type.isNotEmpty ? project.type[0] : '?',
                                style: CustomTextStyles.cairoBold20.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // تعديل هنا لإضافة اسم العميل بين المشروع والتاريخ
                              Text(
                                '${project.type} • ${client.name} • ${project.createdAt.toString().split(' ').first}',
                                style: CustomTextStyles.cairoBold20.copyWith(
                                  fontSize: screenWidth * 0.045,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Text(
                                'الإجمالي: ${payment.amountTotal.toStringAsFixed(2)} • المدفوع: ${payment.amountPaid.toStringAsFixed(2)} • المتبقي: ${payment.remainingAmount.toStringAsFixed(2)}',
                                style: CustomTextStyles.cairoRegular16.copyWith(
                                  color: Colors.grey[700],
                                  fontSize: screenWidth * 0.038,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: screenWidth * 0.07,
                          ),
                          onPressed: () async {
                            final confirmed = await showConfirmDeleteDialog(
                              context,
                              itemName: client.name.isNotEmpty
                                  ? client.name
                                  : 'الدفعية',
                            );

                            if (confirmed == true) {
                              // المستخدم ضغط حذف
                              cubit.deletePayment(payment.id);
                            }
                          },
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
          child: Icon(Icons.add, size: screenWidth * 0.08),
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
    final screenWidth = MediaQuery.of(context).size.width;
    String selectedProjectId = initial.projectId;
    final totalCtrl = TextEditingController(
      text: initial.amountTotal.toString(),
    );
    final paidCtrl = TextEditingController(text: initial.amountPaid.toString());
    DateTime date = initial.datePaid;

    final _formKey = GlobalKey<FormState>(); // ✅ مفتاح الـ Form

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
        ),
        child: Container(
          padding: EdgeInsets.all(screenWidth * 0.05),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.05),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey, // ✅ إضافة الـ Form
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isNew ? 'إضافة دفعة' : 'تعديل دفعة',
                    style: CustomTextStyles.cairoBold20.copyWith(
                      color: AppColors.successGreen,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.04),

                  // Dropdown...
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
                              '${p.type}  • ${p.clientName ?? "غير معروف"}',
                              style: TextStyle(fontSize: screenWidth * 0.04),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => selectedProjectId = v ?? '',
                    decoration: InputDecoration(
                      labelText: 'المشروع',
                      labelStyle: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: screenWidth * 0.045,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.successGreen),
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'اختر المشروع' : null,
                  ),

                  SizedBox(height: screenWidth * 0.03),

                  // المبلغ الإجمالي مع validator
                  TextFormField(
                    controller: totalCtrl,
                    decoration: InputDecoration(
                      labelText: 'المبلغ الإجمالي',
                      labelStyle: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: screenWidth * 0.045,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.successGreen),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final total = double.tryParse(totalCtrl.text) ?? 0;
                      final paid = double.tryParse(paidCtrl.text) ?? -1;

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

                  SizedBox(height: screenWidth * 0.03),

                  // المدفوع
                  TextFormField(
                    controller: paidCtrl,
                    decoration: InputDecoration(
                      labelText: 'المدفوع (دفعة)',
                      labelStyle: TextStyle(
                        color: AppColors.successGreen,
                        fontSize: screenWidth * 0.045,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppColors.successGreen),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final total = double.tryParse(totalCtrl.text) ?? 0;
                      final paid = double.tryParse(value ?? '') ?? -1;
                      if (paid < 0) return 'ادخل مبلغ صحيح';
                      if (paid > total) return 'الدفعة أكبر من الإجمالي';
                      return null;
                    },
                  ),

                  // باقي الكود (التاريخ، الأزرار)...
                  SizedBox(height: screenWidth * 0.04),
                  Row(
                    children: [
                      Text(
                        'التاريخ: ${date.toString().split(' ').first}',
                        style: TextStyle(
                          color: AppColors.successGreen,
                          fontSize: screenWidth * 0.043,
                        ),
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
                          style: TextStyle(
                            color: AppColors.successGreen,
                            fontSize: screenWidth * 0.043,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenWidth * 0.05),
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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.03,
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            final updated = PaymentModel(
                              id: initial.id,
                              projectId: selectedProjectId,
                              amountTotal: double.parse(totalCtrl.text),
                              amountPaid: double.parse(paidCtrl.text),
                              datePaid: date,
                            );
                            if (isNew) {
                              cubit.addPayment(updated);
                            } else {
                              cubit.editPayment(updated);
                            }

                            SnackbarHelper.show(
                              context,
                              message: "تم حفظ الدفعة بنجاح",
                              backgroundColor: AppColors.successGreen,
                            );

                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'حفظ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
