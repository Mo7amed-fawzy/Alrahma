import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

/// =============== custom9 ===============
List<ShapeData> custom9(
  Offset start,
  Offset end,
  Color color,
  double strokeWidth,
) {
  final rect = Rect.fromPoints(start, end);
  final shapes = <ShapeData>[];

  // المستطيل الكبير الأساسي
  shapes.add(
    ShapeData.rect(
      start: rect.topLeft,
      end: rect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  final halfWidth = rect.width / 2;
  final upperHeightForRect = rect.height * 0.36;

  // المستطيل الصغير العلوي
  final smallRect = Rect.fromPoints(
    rect.topLeft,
    Offset(rect.left + halfWidth, rect.top + upperHeightForRect),
  );
  shapes.add(
    ShapeData.rect(
      start: smallRect.topLeft,
      end: smallRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // المستطيل الكبير الجديد اللي يبدأ من نهاية المستطيل الصغير على X
  final largeRect = Rect.fromPoints(
    Offset(smallRect.right, rect.top), // البداية بعد المستطيل الصغير
    rect.bottomRight, // النهاية عند المستطيل الكبير الأصلي
  );
  shapes.add(
    ShapeData.rect(
      start: largeRect.topLeft,
      end: largeRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  return shapes;
}
