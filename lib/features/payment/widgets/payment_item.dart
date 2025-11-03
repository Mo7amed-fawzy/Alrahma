import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/payment_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentItem extends StatelessWidget {
  final PaymentModel payment;
  final ProjectModel project;
  final ClientModel client;
  final double screenWidth;
  final VoidCallback? onTapPayment;
  final VoidCallback? onDelete;

  const PaymentItem({
    super.key,
    required this.payment,
    required this.project,
    required this.client,
    required this.screenWidth,
    this.onTapPayment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentsCubit>();

    final totalPaid = cubit.calculatePaidForProject(
      payment.projectId,
      cubit.state.payments,
    );

    final remaining = cubit.calculateRemainingForProject(
      payment.projectId,
      cubit.state.payments,
    );

    return GestureDetector(
      onTap: onTapPayment,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: EdgeInsets.symmetric(
          vertical: screenWidth * 0.02,
          horizontal: screenWidth * 0.01,
        ),
        padding: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.alrahmaSecondColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: AppColors.alrahmaSecondColor.withValues(alpha: 0.2),
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
                backgroundColor: AppColors.alrahmaSecondColor,
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
                  Text(
                    '${project.type} • ${client.name} • ${project.createdAt.toString().split(' ').first}',
                    style: CustomTextStyles.cairoBold20.copyWith(
                      fontSize: screenWidth * 0.045,
                    ),
                  ),
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    'الإجمالي: ${payment.amountTotal.toStringAsFixed(2)} • '
                    'المدفوع: ${totalPaid.toStringAsFixed(2)} • '
                    'المتبقي: ${remaining.toStringAsFixed(2)}',
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
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
