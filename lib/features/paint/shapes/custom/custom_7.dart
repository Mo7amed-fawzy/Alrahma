import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

/// =============== custom7 ===============
List<ShapeData> custom7(
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
  final halfHeight = rect.height / 2;

  // مسافات فاصلة
  final gapX = rect.width * 0.07; // مسافة أفقية بين الأعمدة
  final gapY = rect.height * 0.00; // مسافة رأسية بين الصفوف

  // ===== مستطيل داخلي للشمال (يغطي فوق وتحت شمال) =====
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

  // ===== مستطيل داخلي لليمين (يغطي فوق وتحت يمين) =====
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

  // ===== الباب الشمال (فوق) =====
  final leftDoorRect = Rect.fromPoints(
    rect.topLeft,
    Offset(rect.left + halfWidth - gapX / 2, rect.top + halfHeight - gapY / 2),
  );
  shapes.add(
    ShapeData.rect(
      start: leftDoorRect.topLeft,
      end: leftDoorRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // ===== الباب اليمين (فوق) =====
  final rightDoorRect = Rect.fromPoints(
    Offset(rect.left + halfWidth + gapX / 2, rect.top),
    Offset(rect.right, rect.top + halfHeight - gapY / 2),
  );
  shapes.add(
    ShapeData.rect(
      start: rightDoorRect.topLeft,
      end: rightDoorRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // ===== المستطيل الفاضي تحت (شمال) =====
  final leftEmptyRect = Rect.fromPoints(
    Offset(rect.left, rect.top + halfHeight + gapY / 2),
    Offset(rect.left + halfWidth - gapX / 2, rect.bottom),
  );
  shapes.add(
    ShapeData.rect(
      start: leftEmptyRect.topLeft,
      end: leftEmptyRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // ===== المستطيل الفاضي تحت (يمين) =====
  final rightEmptyRect = Rect.fromPoints(
    Offset(rect.left + halfWidth + gapX / 2, rect.top + halfHeight + gapY / 2),
    rect.bottomRight,
  );
  shapes.add(
    ShapeData.rect(
      start: rightEmptyRect.topLeft,
      end: rightEmptyRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );
  // ===== مستطيلات داخلية صغيرة في الأبواب =====
  final innerPadding = rect.width * 0.04; // مسافة من فوق وتحت
  final innerPaddingTB = innerPadding; // مسافة من فوق وتحت
  final innerPaddingSide = innerPadding; // مسافة من الجوانب (يمين/شمال)

  // مسافة إضافية علشان تبعد المستطيلين عن الكبير
  final outerGap = rect.width * 0.03;

  // مستطيل داخلي في الباب الشمال
  final leftInnerRect = Rect.fromLTRB(
    leftDoorRect.left + outerGap, // بُعد من الناحية الشمال عن الكبير
    leftDoorRect.top + innerPaddingTB,
    leftDoorRect.right - innerPaddingSide * 2.2,
    leftDoorRect.bottom - innerPaddingTB,
  );
  shapes.add(
    ShapeData.rect(
      start: leftInnerRect.topLeft,
      end: leftInnerRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // مستطيل داخلي في الباب اليمين
  final rightInnerRect = Rect.fromLTRB(
    rightDoorRect.left + innerPaddingSide * 2.2,
    rightDoorRect.top + innerPaddingTB,
    rightDoorRect.right - outerGap, // بُعد من الناحية اليمين عن الكبير
    rightDoorRect.bottom - innerPaddingTB,
  );
  shapes.add(
    ShapeData.rect(
      start: rightInnerRect.topLeft,
      end: rightInnerRect.bottomRight,
      color: color,
      strokeWidth: strokeWidth,
      filled: false,
    ),
  );

  // ===== المقابض =====
  final handleRadius = rect.width * 0.020; // مقاس موحد وصغير شوية

  // مقبض داخلي الباب الشمال
  final leftInnerHandle = Offset(
    leftDoorRect.center.dx + (leftDoorRect.width * 0.2),
    leftDoorRect.center.dy,
  );
  shapes.add(
    ShapeData.circle(
      center: leftInnerHandle,
      radius: handleRadius,
      color: color,
      strokeWidth: strokeWidth,
      filled: true,
    ),
  );

  // مقبض داخلي الباب اليمين
  final rightInnerHandle = Offset(
    rightDoorRect.center.dx - (rightDoorRect.width * 0.2),
    rightDoorRect.center.dy,
  );
  shapes.add(
    ShapeData.circle(
      center: rightInnerHandle,
      radius: handleRadius,
      color: color,
      strokeWidth: strokeWidth,
      filled: true,
    ),
  );

  // مقبض خارجي الباب اليمين (نازل لتحت)
  final rightHandleCenter = Offset(
    rightDoorRect.left + (rect.width * 0.05),
    rightDoorRect.center.dy + rect.height * 0.1,
  );
  shapes.add(
    ShapeData.circle(
      center: rightHandleCenter,
      radius: handleRadius,
      color: color,
      strokeWidth: strokeWidth,
      filled: true,
    ),
  );

  return shapes;
}
