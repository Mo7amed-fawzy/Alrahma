import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

List<ShapeData> custom12(
  Offset start,
  Offset end,
  Color color,
  double strokeWidth,
) {
  final rect = Rect.fromPoints(start, end);
  final shapes = <ShapeData>[];

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

  final quarterWidth = rect.width / 4;
  final upperHeightForRect = rect.height * 0.25;

  // المستطيلات العلوية
  for (int i = 0; i < 4; i++) {
    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left + quarterWidth * i, rect.top),
        end: Offset(
          rect.left + quarterWidth * (i + 1),
          rect.top + upperHeightForRect,
        ),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );
  }

  // الأسهم (زي ما هي عندك)
  final arrowHeight = rect.height * 0.15;
  final arrowWidth = rect.width * 0.60;
  final arrowY = rect.top + rect.height * 0.40;
  final arrowGap = rect.width * 0.05; // مسافة أفقية إضافية بين الأسهم

  // الفوق يمين → شمال
  shapes.add(
    ShapeData.arrow(
      start: Offset(rect.center.dx + arrowWidth / 2 + arrowGap, arrowY),
      end: Offset(rect.center.dx + arrowGap, arrowY),
      color: color,
      strokeWidth: strokeWidth,
    ),
  );

  // التحت يمين → يمين
  shapes.add(
    ShapeData.arrow(
      start: Offset(rect.center.dx + arrowGap, arrowY + arrowHeight),
      end: Offset(
        rect.center.dx + arrowWidth / 2 + arrowGap,
        arrowY + arrowHeight,
      ),
      color: color,
      strokeWidth: strokeWidth,
    ),
  );

  // الفوق شمال → يمين
  shapes.add(
    ShapeData.arrow(
      start: Offset(rect.center.dx - arrowWidth / 2 - arrowGap, arrowY),
      end: Offset(rect.center.dx - arrowGap, arrowY),
      color: color,
      strokeWidth: strokeWidth,
    ),
  );

  // التحت شمال → شمال
  shapes.add(
    ShapeData.arrow(
      start: Offset(rect.center.dx - arrowGap, arrowY + arrowHeight),
      end: Offset(
        rect.center.dx - arrowWidth / 2 - arrowGap,
        arrowY + arrowHeight,
      ),
      color: color,
      strokeWidth: strokeWidth,
    ),
  );

  // المستطيلات السفلية (نفس فكرة العلوية بس تبدأ من rect.bottom - الارتفاع)
  for (int i = 0; i < 4; i++) {
    shapes.add(
      ShapeData.rect(
        start: Offset(
          rect.left + quarterWidth * i,
          rect.bottom - upperHeightForRect,
        ),
        end: Offset(rect.left + quarterWidth * (i + 1), rect.bottom),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );
  }

  return shapes;
}
