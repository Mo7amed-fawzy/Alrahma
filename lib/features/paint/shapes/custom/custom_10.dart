import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

/// =============== custom10 ===============
List<ShapeData> custom10(
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

  final halfWidthAndHight = rect.width / 2;

  // المستطيل الصغير في اليمين (أسفل)
  final rightSmallRect = Rect.fromPoints(
    Offset(rect.left + halfWidthAndHight, rect.top + halfWidthAndHight),
    Offset(rect.right, rect.bottom),
  );
  shapes.add(
    ShapeData.rect(
      start: rightSmallRect.topLeft,
      end: rightSmallRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // مستطيل أصغر داخل المستطيل الصغير في اليمين
  final innerRightRect = Rect.fromPoints(
    Offset(rightSmallRect.left + 5, rightSmallRect.top + 5),
    Offset(rightSmallRect.right - 5, rightSmallRect.bottom - 5),
  );
  shapes.add(
    ShapeData.rect(
      start: innerRightRect.topLeft,
      end: innerRightRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // المستطيل الكبير في اليسار
  final leftLargeRect = Rect.fromPoints(
    rect.topLeft,
    Offset(rect.left + halfWidthAndHight, rect.bottom),
  );
  shapes.add(
    ShapeData.rect(
      start: leftLargeRect.topLeft,
      end: leftLargeRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // مستطيل أصغر داخل المستطيل الكبير في اليسار
  final innerLeftRect = Rect.fromPoints(
    Offset(leftLargeRect.left + 5, leftLargeRect.top + 5),
    Offset(leftLargeRect.right - 5, leftLargeRect.bottom - 5),
  );
  shapes.add(
    ShapeData.rect(
      start: innerLeftRect.topLeft,
      end: innerLeftRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  return shapes;
}
