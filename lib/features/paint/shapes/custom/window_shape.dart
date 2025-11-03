import 'dart:math';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

class WindowShape {
  static List<ShapeData> create({
    required Offset topLeft,
    required Size size,
    required Color color,
    double strokeWidth = 2.0,
    int rows = 2,
    int cols = 2,
    double padding = 6.0,
  }) {
    final shapes = <ShapeData>[];
    final rect = Rect.fromPoints(
      topLeft,
      topLeft + Offset(size.width, size.height),
    );

    // الإطار الخارجي
    shapes.add(
      ShapeData.rect(
        start: rect.topLeft,
        end: rect.bottomRight,
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    // الأبعاد الداخلية بعد خصم الـ padding
    final innerLeft = rect.left + padding;
    final innerTop = rect.top + padding;
    final innerRight = rect.right - padding;
    final innerBottom = rect.bottom - padding;
    final innerWidth = max(0.0, innerRight - innerLeft);
    final innerHeight = max(0.0, innerBottom - innerTop);

    if (innerWidth <= 0 || innerHeight <= 0) {
      return shapes;
    }

    final cellW = innerWidth / cols;
    final cellH = innerHeight / rows;

    // رسم المربعات الداخلية (2x2 أو حسب rows/cols)
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final cellStart = Offset(innerLeft + c * cellW, innerTop + r * cellH);
        final cellEnd = Offset(cellStart.dx + cellW, cellStart.dy + cellH);
        shapes.add(
          ShapeData.rect(
            start: cellStart,
            end: cellEnd,
            color: color,
            strokeWidth: strokeWidth,
            filled: false,
          ),
        );
      }
    }

    return shapes;
  }
}
