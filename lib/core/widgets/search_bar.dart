import 'package:alrahma/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar<C extends StateStreamable<S>, S> extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Color prefixColor;
  final Color fillColor;
  final double borderRadius;
  final Function(BuildContext context, String value) onSearch;
  final bool Function(S state) isEmptyResult;

  const CustomSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon = Icons.search,
    this.prefixColor = AppColors.primaryBlue,
    this.fillColor = Colors.white,
    this.borderRadius = 12,
    required this.onSearch,
    required this.isEmptyResult,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, S>(
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent, // علشان يستقبل التابات
          onTap: () {
            FocusScope.of(context).unfocus(); // يقفل الكيبورد
          },
          child: Container(
            // padding خفيف حوالين التكست فيلد علشان المساحة تضغط
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 2.w),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: Icon(prefixIcon, color: prefixColor),
                suffixIcon: controller.text.trim().isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          controller.clear();
                          onSearch(context, ''); // reset الـ filter
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,

                filled: true,
                fillColor: fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(borderRadius.r),
                  borderSide: BorderSide(color: prefixColor, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 16.w,
                ),
              ),
              onChanged: (value) => onSearch(context, value),
            ),
          ),
        );
      },
    );
  }
}
