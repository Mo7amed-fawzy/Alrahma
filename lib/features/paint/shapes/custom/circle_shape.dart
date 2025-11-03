import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

class CircleShape {
  static ShapeData fromPoints({
    required Offset start,
    required Offset end,
    required Color color,
    double strokeWidth = 2.0,
    bool filled = false,
  }) {
    final radius = (end - start).distance / 2;
    final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
    return ShapeData.circle(
      center: center,
      radius: radius,
      color: color,
      strokeWidth: strokeWidth,
      filled: filled,
    );
  }
}
