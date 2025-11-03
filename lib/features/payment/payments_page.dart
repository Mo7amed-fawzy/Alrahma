import 'package:alrahma/core/models/payment_model.dart';
import 'package:alrahma/core/widgets/custom_app_bar.dart';
import 'package:alrahma/core/widgets/show_confirm_delete_dialog.dart';
import 'package:alrahma/features/home/widgets/build_premium_loader.dart';
import 'package:alrahma/features/payment/dialogs/open_payment_dialog.dart';
import 'package:alrahma/features/payment/widgets/add_payment_button.dart';
import 'package:alrahma/features/payment/widgets/payment_item.dart';
import 'package:alrahma/features/payment/widgets/payments_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/app_colors.dart';
import 'cubit/payments_cubit.dart';

class PaymentsPageContent extends StatelessWidget {
  const PaymentsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: customAppBar(
            'الدفعات',
            AppColors.alrahmaSecondColor,
            context,
          ),
          body: BlocBuilder<PaymentsCubit, PaymentsState>(
            builder: (context, state) {
              if (state.isLoading) {
                return Center(child: buildPremiumLoader());
              }

              return PaymentsList(
                screenWidth: screenWidth,
                itemBuilder: (payment, project, client, cubit) => PaymentItem(
                  payment: payment,
                  project: project,
                  client: client,
                  screenWidth: screenWidth,
                  onTapPayment: () {
                    openPaymentDialog(context, payment, cubit);
                  },
                  onDelete: () async {
                    final confirmed = await showConfirmDeleteDialog(
                      context,
                      itemName: client.name.isNotEmpty
                          ? client.name
                          : 'الدفعية',
                    );
                    if (confirmed == true) cubit.deletePayment(payment.id);
                  },
                ),
              );
            },
          ),
          floatingActionButton: AddPaymentButton(
            screenWidth: screenWidth,
            onPressed: () {
              final cubit = context.read<PaymentsCubit>();
              final id = DateTime.now().millisecondsSinceEpoch.toString();
              openPaymentDialog(
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
          ),
        ),
      ),
    );
  }
}
