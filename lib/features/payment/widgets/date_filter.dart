import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DateFilter extends StatelessWidget {
  final double screenWidth;
  const DateFilter({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentsCubit>();
    final dates = cubit.state.availableDates; // ✅ من الـ state

    // if (dates.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: screenWidth * 0.50,
        child: DropdownButtonFormField<DateTime?>(
          decoration: InputDecoration(
            labelText: "التاريخ",
            labelStyle: TextStyle(color: AppColors.alrahmaSecondColor),
            prefixIcon: Icon(
              Icons.calendar_today,
              color: AppColors.alrahmaSecondColor,
            ),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.03,
              vertical: screenWidth * 0.01,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.alrahmaSecondColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          dropdownColor: Colors.white,
          value: null,
          items: [
            DropdownMenuItem<DateTime?>(
              value: null,
              child: Text(
                "الكل",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...dates.map(
              (d) => DropdownMenuItem<DateTime>(
                value: d,
                child: Text(
                  "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
          onChanged: (date) => cubit.filterByDate(date),
        ),
      ),
    );
  }
}
