import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/payment_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/core/widgets/search_bar.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:alrahma/features/payment/widgets/date_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentsList extends StatefulWidget {
  final double screenWidth;
  final Widget Function(
    PaymentModel payment,
    ProjectModel project,
    ClientModel client,
    PaymentsCubit cubit,
  )
  itemBuilder;

  const PaymentsList({
    super.key,
    required this.screenWidth,
    required this.itemBuilder,
  });

  @override
  State<PaymentsList> createState() => _PaymentsListState();
}

class _PaymentsListState extends State<PaymentsList> {
  late final PaymentsCubit cubit;
  late final TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    cubit = context.read<PaymentsCubit>();
    searchController = TextEditingController();
    // Optional: listen to controller changes if needed
    searchController.addListener(() {
      cubit.filterPayments(searchController.text);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(widget.screenWidth * 0.04),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: EdgeInsets.all(widget.screenWidth * 0.03),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSearchBar<PaymentsCubit, PaymentsState>(
                    controller: searchController,
                    hintText: 'ابحث عن دفعة...',
                    prefixColor: AppColors.alrahmaSecondColor,
                    onSearch: (context, value) => cubit.filterPayments(value),
                    isEmptyResult: (state) => state.filteredPayments.isEmpty,
                  ),
                  SizedBox(height: widget.screenWidth * 0.03),
                  DateFilter(screenWidth: widget.screenWidth),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: BlocBuilder<PaymentsCubit, PaymentsState>(
            builder: (context, state) {
              if (state.filteredPayments.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد دفعات',
                    style: CustomTextStyles.cairoRegular18.copyWith(
                      fontSize: widget.screenWidth * 0.045,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.screenWidth * 0.04,
                  vertical: widget.screenWidth * 0.03,
                ),
                itemCount: state.filteredPayments.length,
                itemBuilder: (context, index) {
                  final payment = state.filteredPayments[index];
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
                  final client = state.clients.firstWhere(
                    (c) => c.id == project.clientId,
                    orElse: () => ClientModel(
                      id: '',
                      name: 'غير معروف',
                      phone: '',
                      address: '',
                    ),
                  );

                  return widget.itemBuilder(payment, project, client, cubit);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
