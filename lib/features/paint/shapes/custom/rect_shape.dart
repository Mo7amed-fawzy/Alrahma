import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

class RectShape {
  static ShapeData fromPoints({
    required Offset start,
    required Offset end,
    required Color color,
    double strokeWidth = 2.0,
    bool filled = false,
  }) {
    return ShapeData.rect(
      start: start,
      end: end,
      color: color,
      strokeWidth: strokeWidth,
      filled: filled,
    );
  }
}
