import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/features/paint/shapes/custom/custom_10.dart';
import 'package:alrahma/features/paint/shapes/custom/custom_11.dart';
import 'package:alrahma/features/paint/shapes/custom/custom_12.dart';
import 'package:alrahma/features/paint/shapes/custom/custom_7.dart';
import 'package:alrahma/features/paint/shapes/custom/custom_8.dart';
import 'package:alrahma/features/paint/shapes/custom/custom_9.dart';
import 'package:flutter/material.dart';

class CustomShapes {
  static List<ShapeData> fromTool(
    String tool,
    Offset start,
    Offset end,
    Color color,
    double strokeWidth,
  ) {
    switch (tool) {
      case "custom1":
        return _custom1(start, end, color, strokeWidth);
      case "custom2":
        return _custom2(start, end, color, strokeWidth);
      case "custom3":
        return _custom3(start, end, color, strokeWidth);
      case "custom4":
        return _custom4(start, end, color, strokeWidth);
      case "custom5":
        return _custom5(start, end, color, strokeWidth);
      case "custom6":
        return _custom6(start, end, color, strokeWidth);
      case "custom7":
        return custom7(start, end, color, strokeWidth);
      case "custom8":
        return custom8(start, end, color, strokeWidth);
      case "custom9":
        return custom9(start, end, color, strokeWidth);
      case "custom10":
        return custom10(start, end, color, strokeWidth);
      case "custom11":
        return custom11(start, end, color, strokeWidth);
      case "custom12":
        return custom12(start, end, color, strokeWidth);
      default:
        return [];
    }
  }

  /// =============== custom1 ===============
  static List<ShapeData> _custom1(
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

    final halfWidth = rect.width / 2;
    final upperHeight = rect.height * 0.60;
    final upperHeightForRect = rect.height * 0.30;

    shapes.add(
      ShapeData.rect(
        start: rect.topLeft,
        end: Offset(rect.left + halfWidth, rect.top + upperHeightForRect),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left + halfWidth, rect.top),
        end: Offset(rect.right, rect.top + upperHeightForRect),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    final triangleBaseWidth = rect.width * 0.56;
    final centerX = rect.center.dx;

    final triangleBaseLeft = Offset(
      centerX - triangleBaseWidth / 2,
      rect.bottom,
    );
    final triangleBaseRight = Offset(
      centerX + triangleBaseWidth / 2,
      rect.bottom,
    );
    final triangleApex = Offset(centerX, rect.bottom - upperHeight);

    final path = Path()
      ..moveTo(triangleApex.dx, triangleApex.dy)
      ..lineTo(triangleBaseLeft.dx, triangleBaseLeft.dy)
      ..lineTo(triangleBaseRight.dx, triangleBaseRight.dy)
      ..close();

    shapes.add(
      ShapeData.path(path: path, color: color, strokeWidth: strokeWidth),
    );

    return shapes;
  }

  /// =============== custom2 ===============
  static List<ShapeData> _custom2(
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

    final triangleHeight = rect.height * 0.56;
    final triangleBaseWidth = rect.width * 0.9;

    final leftApex = Offset(rect.left + triangleBaseWidth / 2, rect.center.dy);
    final leftBaseTop = Offset(rect.left, rect.center.dy - triangleHeight / 2);
    final leftBaseBottom = Offset(
      rect.left,
      rect.center.dy + triangleHeight / 2,
    );

    final leftPath = Path()
      ..moveTo(leftApex.dx, leftApex.dy)
      ..lineTo(leftBaseTop.dx, leftBaseTop.dy)
      ..lineTo(leftBaseBottom.dx, leftBaseBottom.dy)
      ..close();

    shapes.add(
      ShapeData.path(path: leftPath, color: color, strokeWidth: strokeWidth),
    );

    final rightApex = Offset(
      rect.right - triangleBaseWidth / 2,
      rect.center.dy,
    );
    final rightBaseTop = Offset(
      rect.right,
      rect.center.dy - triangleHeight / 2,
    );
    final rightBaseBottom = Offset(
      rect.right,
      rect.center.dy + triangleHeight / 2,
    );

    final rightPath = Path()
      ..moveTo(rightApex.dx, rightApex.dy)
      ..lineTo(rightBaseTop.dx, rightBaseTop.dy)
      ..lineTo(rightBaseBottom.dx, rightBaseBottom.dy)
      ..close();

    shapes.add(
      ShapeData.path(path: rightPath, color: color, strokeWidth: strokeWidth),
    );

    return shapes;
  }

  /// =============== custom3 ===============
  static List<ShapeData> _custom3(
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

    final triangleHeight = rect.height * 0.56;
    final triangleBaseWidth = rect.width * 0.7;

    // Left big triangle
    final leftApex = Offset(rect.left + triangleBaseWidth / 2, rect.center.dy);
    final leftBaseTop = Offset(rect.left, rect.center.dy - triangleHeight / 2);
    final leftBaseBottom = Offset(
      rect.left,
      rect.center.dy + triangleHeight / 2,
    );

    final leftPath = Path()
      ..moveTo(leftApex.dx, leftApex.dy)
      ..lineTo(leftBaseTop.dx, leftBaseTop.dy)
      ..lineTo(leftBaseBottom.dx, leftBaseBottom.dy)
      ..close();

    shapes.add(
      ShapeData.path(path: leftPath, color: color, strokeWidth: strokeWidth),
    );

    // Right big triangle
    final rightApex = Offset(
      rect.right - triangleBaseWidth / 2,
      rect.center.dy,
    );
    final rightBaseTop = Offset(
      rect.right,
      rect.center.dy - triangleHeight / 2,
    );
    final rightBaseBottom = Offset(
      rect.right,
      rect.center.dy + triangleHeight / 2,
    );

    final rightPath = Path()
      ..moveTo(rightApex.dx, rightApex.dy)
      ..lineTo(rightBaseTop.dx, rightBaseTop.dy)
      ..lineTo(rightBaseBottom.dx, rightBaseBottom.dy)
      ..close();

    shapes.add(
      ShapeData.path(path: rightPath, color: color, strokeWidth: strokeWidth),
    );

    // Helper to scale triangles
    Offset scalePoint(Offset p, Offset anchor, double factor) {
      return Offset(
        anchor.dx + (p.dx - anchor.dx) * factor,
        anchor.dy + (p.dy - anchor.dy) * factor,
      );
    }

    double scale = 0.5;

    // Small left triangle
    final leftBaseCenter = Offset(
      (leftBaseTop.dx + leftBaseBottom.dx) / 2,
      (leftBaseTop.dy + leftBaseBottom.dy) / 2,
    );

    final leftSmallApex = scalePoint(leftApex, leftBaseCenter, scale);
    final leftSmallBaseTop = scalePoint(leftBaseTop, leftBaseCenter, scale);
    final leftSmallBaseBottom = scalePoint(
      leftBaseBottom,
      leftBaseCenter,
      scale,
    );

    final leftSmallPath = Path()
      ..moveTo(leftSmallApex.dx, leftSmallApex.dy)
      ..lineTo(leftSmallBaseTop.dx, leftSmallBaseTop.dy)
      ..lineTo(leftSmallBaseBottom.dx, leftSmallBaseBottom.dy)
      ..close();

    shapes.add(
      ShapeData.path(
        path: leftSmallPath,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );

    // Small right triangle
    final rightBaseCenter = Offset(
      (rightBaseTop.dx + rightBaseBottom.dx) / 2,
      (rightBaseTop.dy + rightBaseBottom.dy) / 2,
    );

    final rightSmallApex = scalePoint(rightApex, rightBaseCenter, scale);
    final rightSmallBaseTop = scalePoint(rightBaseTop, rightBaseCenter, scale);
    final rightSmallBaseBottom = scalePoint(
      rightBaseBottom,
      rightBaseCenter,
      scale,
    );

    final rightSmallPath = Path()
      ..moveTo(rightSmallApex.dx, rightSmallApex.dy)
      ..lineTo(rightSmallBaseTop.dx, rightSmallBaseTop.dy)
      ..lineTo(rightSmallBaseBottom.dx, rightSmallBaseBottom.dy)
      ..close();

    shapes.add(
      ShapeData.path(
        path: rightSmallPath,
        color: color,
        strokeWidth: strokeWidth,
      ),
    );

    return shapes;
  }

  /// =============== custom4 ===============
  static List<ShapeData> _custom4(
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

    final halfWidth = rect.width / 2;
    final upperHeightForRect = rect.height * 0.25;

    shapes.add(
      ShapeData.rect(
        start: rect.topLeft,
        end: Offset(rect.left + halfWidth, rect.top + upperHeightForRect),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left + halfWidth, rect.top),
        end: Offset(rect.right, rect.top + upperHeightForRect),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    final arrowHeight = rect.height * 0.15;
    final arrowWidth = rect.width * 0.60;
    final arrowY = rect.top + rect.height * 0.40;

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

  /// =============== custom5 ===============
  static List<ShapeData> _custom5(
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

    final halfWidth = rect.width / 2;
    final lowerHeightForRect = rect.height * 0.25;

    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left, rect.bottom - lowerHeightForRect),
        end: Offset(rect.left + halfWidth, rect.bottom),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left + halfWidth, rect.bottom - lowerHeightForRect),
        end: Offset(rect.right, rect.bottom),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    final arrowHeight = rect.height * 0.20;
    final arrowHeightforbuttom = rect.height * 0.02;
    final arrowWidth = rect.width * 0.60;

    final arrowsTopY = rect.center.dy - arrowHeight;
    final arrowsBottomY = rect.center.dy - arrowHeightforbuttom;

    shapes.add(
      ShapeData.arrow(
        start: Offset(rect.center.dx + arrowWidth / 2, arrowsTopY),
        end: Offset(rect.center.dx - arrowWidth / 2, arrowsTopY),
        color: color,
        strokeWidth: strokeWidth,
      ),
    );

    shapes.add(
      ShapeData.arrow(
        start: Offset(rect.center.dx - arrowWidth / 2, arrowsBottomY),
        end: Offset(rect.center.dx + arrowWidth / 2, arrowsBottomY),
        color: color,
        strokeWidth: strokeWidth,
      ),
    );

    return shapes;
  }

  /// =============== custom6 ===============
  static List<ShapeData> _custom6(
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
    shapes.add(
      ShapeData.rect(
        start: rect.topLeft,
        end: Offset(rect.left + quarterWidth, rect.top + upperHeightForRect),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left + quarterWidth, rect.top),
        end: Offset(
          rect.left + quarterWidth * 2,
          rect.top + upperHeightForRect,
        ),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left + quarterWidth * 2, rect.top),
        end: Offset(
          rect.left + quarterWidth * 3,
          rect.top + upperHeightForRect,
        ),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    shapes.add(
      ShapeData.rect(
        start: Offset(rect.left + quarterWidth * 3, rect.top),
        end: Offset(
          rect.left + quarterWidth * 4,
          rect.top + upperHeightForRect,
        ),
        color: color,
        strokeWidth: strokeWidth,
        filled: false,
      ),
    );

    // إعداد الأسهم
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

    return shapes;
  }
}
