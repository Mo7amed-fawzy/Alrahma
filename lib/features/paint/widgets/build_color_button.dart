import 'package:flutter/material.dart';

import '../cubit/drawing_canvas_cubit.dart';

Widget buildColorButton(DrawingCanvasCubit cubit, Color color) {
  final isActive = cubit.state.selectedColor == color;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: InkWell(
      onTap: () => cubit.changeColor(color),
      borderRadius: BorderRadius.circular(50),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isActive ? Border.all(color: Colors.orange, width: 3) : null,
          boxShadow: isActive
              ? [BoxShadow(color: color.withOpacity(0.6), blurRadius: 10)]
              : [],
        ),
        child: CircleAvatar(radius: 14, backgroundColor: color),
      ),
    ),
  );
}
