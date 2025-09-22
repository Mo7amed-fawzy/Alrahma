import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

/// =============== custom8 ===============
List<ShapeData> custom8(
  Offset start,
  Offset end,
  Color color,
  double strokeWidth,
) {
  final shapes = <ShapeData>[];

  final rect = Rect.fromPoints(start, end);

  // مستطيل خارجي أكبر يحيط بكل الرسمة
  final outerPadding = rect.width * 0.05; // مسافة padding حوالين الإطار
  final outerRect = Rect.fromPoints(
    Offset(rect.left - outerPadding, rect.top - outerPadding),
    Offset(rect.right + outerPadding, rect.bottom + outerPadding),
  );
  shapes.add(
    ShapeData.rect(
      start: outerRect.topLeft,
      end: outerRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  final halfWidth = rect.width / 2;
  final gapX = rect.width * 0.07; // مسافة أفقية بين الأعمدة

  final leftBigRect = Rect.fromPoints(
    rect.topLeft,
    Offset(rect.left + halfWidth - gapX / 2, rect.bottom),
  );
  shapes.add(
    ShapeData.rect(
      start: leftBigRect.topLeft,
      end: leftBigRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  final rightBigRect = Rect.fromPoints(
    Offset(rect.left + halfWidth + gapX / 2, rect.top),
    rect.bottomRight,
  );
  shapes.add(
    ShapeData.rect(
      start: rightBigRect.topLeft,
      end: rightBigRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // الخط اللي يربط المستطيلين من فوق كـ path
  final topLeftPoint = Offset(leftBigRect.right, leftBigRect.top);
  final topRightPoint = Offset(rightBigRect.left, rightBigRect.top);

  final path = Path()
    ..moveTo(topLeftPoint.dx, topLeftPoint.dy)
    ..lineTo(topRightPoint.dx, topRightPoint.dy);

  shapes.add(
    ShapeData.path(
      path: path,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  return shapes;
}
