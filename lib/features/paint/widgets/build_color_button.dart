import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/drawing_canvas_cubit.dart';

Widget buildColorButton(DrawingCanvasCubit cubit, Color color) {
  final isActive = cubit.state.selectedColor == color;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 4.w),
    child: InkWell(
      onTap: () => cubit.changeColor(color),
      borderRadius: BorderRadius.circular(50.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isActive
              ? Border.all(color: Colors.orange, width: 3.w)
              : null,
          boxShadow: isActive
              ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10.r)]
              : [],
        ),
        child: CircleAvatar(radius: 14.r, backgroundColor: color),
      ),
    ),
  );
}
