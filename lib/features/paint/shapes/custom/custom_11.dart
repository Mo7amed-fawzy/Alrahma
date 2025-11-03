import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

/// =============== custom11 ===============

List<ShapeData> custom11(
  Offset start,
  Offset end,
  Color color,
  double strokeWidth,
) {
  final rect = Rect.fromPoints(start, end);
  final shapes = <ShapeData>[];

  shapes.add(
    ShapeData.rect(
      start: rect.topLeft,
      end: rect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  final arrowHeight = rect.height * 0.35;
  final arrowWidth = rect.width * 0.60;
  final arrowY = rect.top + rect.height * 0.20;

  shapes.add(
    ShapeData.arrow(
      start: Offset(rect.center.dx + arrowWidth / 2, arrowY),
      end: Offset(rect.center.dx - arrowWidth / 2, arrowY),
      color: color,
      strokeWidth: strokeWidth,
    ),
  );

  shapes.add(
    ShapeData.arrow(
      start: Offset(rect.center.dx - arrowWidth / 2, arrowY + arrowHeight),
      end: Offset(rect.center.dx + arrowWidth / 2, arrowY + arrowHeight),
      color: color,
      strokeWidth: strokeWidth,
    ),
  );

  return shapes;
}
