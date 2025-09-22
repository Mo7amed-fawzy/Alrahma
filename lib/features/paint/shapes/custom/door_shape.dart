import 'dart:math';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

class DoorShape {
  static List<ShapeData> create({
    required Offset topLeft,
    required Size size,
    required Color color,
    double strokeWidth = 2.0,
  }) {
    final rectStart = topLeft;
    final rectEnd = topLeft + Offset(size.width, size.height);
    final outer = ShapeData.rect(
      start: rectStart,
      end: rectEnd,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    );

    final r = Rect.fromPoints(rectStart, rectEnd);
    final handleOffsetX = max(6.0, r.width * 0.08);
    final handleCenter = Offset(r.right - handleOffsetX, r.center.dy);
    final handleRadius = max(3.0, min(r.width, r.height) * 0.03);

    final handle = ShapeData.circle(
      center: handleCenter,
      radius: handleRadius,
      color: color,
      strokeWidth: strokeWidth,
      filled: true,
    );

    return [outer, handle];
  }
}
