// // shape_factory.dart
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:alrahma/core/models/drawing_model.dart';

// class ShapeFactory {
//   /// Creates a rectangle ShapeData from start/end points
//   static ShapeData fromRectPoints({
//     required Offset start,
//     required Offset end,
//     required Color color,
//     double strokeWidth = 2.0,
//     bool filled = false,
//   }) {
//     return ShapeData.rect(
//       start: start,
//       end: end,
//       color: color,
//       strokeWidth: strokeWidth,
//       filled: filled,
//     );
//   }

//   /// Creates a circle ShapeData from start/end points (interpreted as bounding box)
//   static ShapeData fromCirclePoints({
//     required Offset start,
//     required Offset end,
//     required Color color,
//     double strokeWidth = 2.0,
//     bool filled = false,
//   }) {
//     final radius = (end - start).distance / 2;
//     final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
//     return ShapeData.circle(
//       center: center,
//       radius: radius,
//       color: color,
//       strokeWidth: strokeWidth,
//       filled: filled,
//     );
//   }

//   /// Create door composed of an outer rect + a small circle for handle.
//   static List<ShapeData> createDoor({
//     required Offset topLeft,
//     required Size size,
//     required Color color,
//     double strokeWidth = 2.0,
//   }) {
//     final rectStart = topLeft;
//     final rectEnd = topLeft + Offset(size.width, size.height);
//     final outer = ShapeData.rect(
//       start: rectStart,
//       end: rectEnd,
//       color: color,
//       strokeWidth: strokeWidth,
//       filled: false,
//     );

//     final r = Rect.fromPoints(rectStart, rectEnd);
//     final handleOffsetX = max(6.0, r.width * 0.08);
//     final handleCenter = Offset(r.right - handleOffsetX, r.center.dy);
//     final handleRadius = max(3.0, min(r.width, r.height) * 0.03);

//     final handle = ShapeData.circle(
//       center: handleCenter,
//       radius: handleRadius,
//       color: color,
//       strokeWidth: strokeWidth,
//       filled: true,
//     );

//     return [outer, handle];
//   }

//   /// Create a simple window: outer frame + 4 pane rects (2x2)
//   static List<ShapeData> createWindow({
//     required Offset topLeft,
//     required Size size,
//     required Color color,
//     double strokeWidth = 2.0,
//     int rows = 2,
//     int cols = 2,
//     double padding = 6.0,
//   }) {
//     final shapes = <ShapeData>[];
//     final rect = Rect.fromPoints(
//       topLeft,
//       topLeft + Offset(size.width, size.height),
//     );

//     shapes.add(
//       ShapeData.rect(
//         start: rect.topLeft,
//         end: rect.bottomRight,
//         color: color,
//         strokeWidth: strokeWidth,
//         filled: false,
//       ),
//     );

//     final innerLeft = rect.left + padding;
//     final innerTop = rect.top + padding;
//     final innerRight = rect.right - padding;
//     final innerBottom = rect.bottom - padding;
//     final innerWidth = max(0.0, innerRight - innerLeft);
//     final innerHeight = max(0.0, innerBottom - innerTop);

//     if (innerWidth <= 0 || innerHeight <= 0) {
//       return shapes;
//     }

//     final cellW = innerWidth / cols;
//     final cellH = innerHeight / rows;

//     for (int r = 0; r < rows; r++) {
//       for (int c = 0; c < cols; c++) {
//         final cellStart = Offset(innerLeft + c * cellW, innerTop + r * cellH);
//         final cellEnd = Offset(cellStart.dx + cellW, cellStart.dy + cellH);
//         shapes.add(
//           ShapeData.rect(
//             start: cellStart,
//             end: cellEnd,
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );
//       }
//     }

//     return shapes;
//   }

//   /// Draw a ShapeData to canvas
//   static void drawShape(Canvas canvas, ShapeData s, Paint paint) {
//     switch (s.type) {
//       case "rect":
//         if (s.start != null && s.end != null) {
//           canvas.drawRect(Rect.fromPoints(s.start!, s.end!), paint);
//         }
//         break;

//       case "circle":
//         if (s.center != null && s.radius != null) {
//           if (s.filled) {
//             final fillPaint = Paint()
//               ..color = s.color
//               ..style = PaintingStyle.fill;
//             canvas.drawCircle(s.center!, s.radius!, fillPaint);
//             if (s.strokeWidth > 0) {
//               final strokePaint = Paint()
//                 ..color = s.color
//                 ..style = PaintingStyle.stroke
//                 ..strokeWidth = s.strokeWidth;
//               canvas.drawCircle(s.center!, s.radius!, strokePaint);
//             }
//           } else {
//             canvas.drawCircle(s.center!, s.radius!, paint);
//           }
//         }
//         break;

//       case "path":
//       case "triangle":
//       case "arrow":
//         if (s.path != null) {
//           canvas.drawPath(s.path!, paint);
//         }
//         break;

//       default:
//         break;
//     }
//   }

//   static List<ShapeData> fromTool({
//     required String tool,
//     required Offset start,
//     required Offset end,
//     required Color color,
//     required double strokeWidth,
//   }) {
//     switch (tool) {
//       case "rect":
//         return [
//           ShapeFactory.fromRectPoints(
//             start: start,
//             end: end,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         ];

//       case "circle":
//         return [
//           ShapeFactory.fromCirclePoints(
//             start: start,
//             end: end,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         ];

//       case "door":
//         return ShapeFactory.createDoor(
//           topLeft: start,
//           size: Size(end.dx - start.dx, end.dy - start.dy),
//           color: color,
//           strokeWidth: strokeWidth,
//         );

//       case "window":
//         return ShapeFactory.createWindow(
//           topLeft: start,
//           size: Size(end.dx - start.dx, end.dy - start.dy),
//           color: color,
//           strokeWidth: strokeWidth,
//         );

//       case "triangle":
//         return [
//           ShapeData.triangle(
//             start: start,
//             end: end,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         ];

//       case "arrow":
//         return [
//           ShapeData.arrow(
//             start: start,
//             end: end,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         ];

//       // 👇 الشكل custom1 (مربع + 2 فوق + مثلث تحت)
//       case "custom1":
//         final rect = Rect.fromPoints(start, end);
//         final shapes = <ShapeData>[];

//         // الإطار الخارجي
//         shapes.add(
//           ShapeData.rect(
//             start: rect.topLeft,
//             end: rect.bottomRight,
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         final halfWidth = rect.width / 2;
//         final upperHeight = rect.height * 0.60;
//         final upperHeightForRect = rect.height * 0.30;

//         shapes.add(
//           ShapeData.rect(
//             start: rect.topLeft,
//             end: Offset(rect.left + halfWidth, rect.top + upperHeightForRect),
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         shapes.add(
//           ShapeData.rect(
//             start: Offset(rect.left + halfWidth, rect.top),
//             end: Offset(rect.right, rect.top + upperHeightForRect),
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         // المثلث في الأسفل، قاعدة أصغر من عرض المستطيل
//         final triangleBaseWidth = rect.width * 0.56; // 40% من عرض المستطيل
//         final centerX = rect.center.dx;

//         final triangleBaseLeft = Offset(
//           centerX - triangleBaseWidth / 2,
//           rect.bottom,
//         ); // يسار القاعدة
//         final triangleBaseRight = Offset(
//           centerX + triangleBaseWidth / 2,
//           rect.bottom,
//         ); // يمين القاعدة
//         final triangleApex = Offset(
//           centerX,
//           rect.bottom - upperHeight,
//         ); // رأس المثلث للأعلى

//         final path = Path()
//           ..moveTo(triangleApex.dx, triangleApex.dy) // رأس المثلث
//           ..lineTo(triangleBaseLeft.dx, triangleBaseLeft.dy) // الزاوية اليسرى
//           ..lineTo(triangleBaseRight.dx, triangleBaseRight.dy) // الزاوية اليمنى
//           ..close();

//         shapes.add(
//           ShapeData.path(path: path, color: color, strokeWidth: strokeWidth),
//         );

//         return shapes;

//       case "custom2":
//         final rect = Rect.fromPoints(start, end);
//         final shapes = <ShapeData>[];

//         // الإطار الخارجي
//         shapes.add(
//           ShapeData.rect(
//             start: rect.topLeft,
//             end: rect.bottomRight,
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         // حجم المثلثات (مثلاً 30% من ارتفاع المستطيل)
//         final triangleHeight = rect.height * 0.56;
//         final triangleBaseWidth =
//             rect.width * 0.9; // قاعدة كل مثلث 30% من عرض المستطيل

//         // المثلث الأيسر
//         final leftApex = Offset(
//           rect.left + triangleBaseWidth / 2,
//           rect.center.dy,
//         ); // رأس المثلث للداخل
//         final leftBaseTop = Offset(
//           rect.left,
//           rect.center.dy - triangleHeight / 2,
//         );
//         final leftBaseBottom = Offset(
//           rect.left,
//           rect.center.dy + triangleHeight / 2,
//         );

//         final leftPath = Path()
//           ..moveTo(leftApex.dx, leftApex.dy)
//           ..lineTo(leftBaseTop.dx, leftBaseTop.dy)
//           ..lineTo(leftBaseBottom.dx, leftBaseBottom.dy)
//           ..close();

//         shapes.add(
//           ShapeData.path(
//             path: leftPath,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         // المثلث الأيمن
//         final rightApex = Offset(
//           rect.right - triangleBaseWidth / 2,
//           rect.center.dy,
//         ); // رأس المثلث للداخل
//         final rightBaseTop = Offset(
//           rect.right,
//           rect.center.dy - triangleHeight / 2,
//         );
//         final rightBaseBottom = Offset(
//           rect.right,
//           rect.center.dy + triangleHeight / 2,
//         );

//         final rightPath = Path()
//           ..moveTo(rightApex.dx, rightApex.dy)
//           ..lineTo(rightBaseTop.dx, rightBaseTop.dy)
//           ..lineTo(rightBaseBottom.dx, rightBaseBottom.dy)
//           ..close();

//         shapes.add(
//           ShapeData.path(
//             path: rightPath,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         return shapes;

//       case "custom3":
//         final rect = Rect.fromPoints(start, end);
//         final shapes = <ShapeData>[];

//         // الإطار الخارجي
//         shapes.add(
//           ShapeData.rect(
//             start: rect.topLeft,
//             end: rect.bottomRight,
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         // حجم المثلثات الكبيرة
//         final triangleHeight = rect.height * 0.56;
//         final triangleBaseWidth = rect.width * 0.7;

//         // --------- المثلث الأيسر الكبير ---------
//         final leftApex = Offset(
//           rect.left + triangleBaseWidth / 2,
//           rect.center.dy,
//         );
//         final leftBaseTop = Offset(
//           rect.left,
//           rect.center.dy - triangleHeight / 2,
//         );
//         final leftBaseBottom = Offset(
//           rect.left,
//           rect.center.dy + triangleHeight / 2,
//         );

//         final leftPath = Path()
//           ..moveTo(leftApex.dx, leftApex.dy)
//           ..lineTo(leftBaseTop.dx, leftBaseTop.dy)
//           ..lineTo(leftBaseBottom.dx, leftBaseBottom.dy)
//           ..close();

//         shapes.add(
//           ShapeData.path(
//             path: leftPath,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         // --------- المثلث الأيمن الكبير ---------
//         final rightApex = Offset(
//           rect.right - triangleBaseWidth / 2,
//           rect.center.dy,
//         );
//         final rightBaseTop = Offset(
//           rect.right,
//           rect.center.dy - triangleHeight / 2,
//         );
//         final rightBaseBottom = Offset(
//           rect.right,
//           rect.center.dy + triangleHeight / 2,
//         );

//         final rightPath = Path()
//           ..moveTo(rightApex.dx, rightApex.dy)
//           ..lineTo(rightBaseTop.dx, rightBaseTop.dy)
//           ..lineTo(rightBaseBottom.dx, rightBaseBottom.dy)
//           ..close();

//         shapes.add(
//           ShapeData.path(
//             path: rightPath,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );
//         // --------- function لعمل scaling حوالين نقطة معينة ---------
//         Offset scalePoint(Offset p, Offset anchor, double factor) {
//           return Offset(
//             anchor.dx + (p.dx - anchor.dx) * factor,
//             anchor.dy + (p.dy - anchor.dy) * factor,
//           );
//         }

//         // --------- المثلث الأيسر الصغير ---------
//         double scale = 0.5; // ⬅️ تحكم في حجم المثلث الصغير

//         // نقطة الارتكاز: منتصف القاعدة (الخط بين BaseTop و BaseBottom)
//         final leftBaseCenter = Offset(
//           (leftBaseTop.dx + leftBaseBottom.dx) / 2,
//           (leftBaseTop.dy + leftBaseBottom.dy) / 2,
//         );

//         final leftSmallApex = scalePoint(leftApex, leftBaseCenter, scale);
//         final leftSmallBaseTop = scalePoint(leftBaseTop, leftBaseCenter, scale);
//         final leftSmallBaseBottom = scalePoint(
//           leftBaseBottom,
//           leftBaseCenter,
//           scale,
//         );

//         final leftSmallPath = Path()
//           ..moveTo(leftSmallApex.dx, leftSmallApex.dy)
//           ..lineTo(leftSmallBaseTop.dx, leftSmallBaseTop.dy)
//           ..lineTo(leftSmallBaseBottom.dx, leftSmallBaseBottom.dy)
//           ..close();

//         shapes.add(
//           ShapeData.path(
//             path: leftSmallPath,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         // --------- المثلث الأيمن الصغير ---------
//         final rightBaseCenter = Offset(
//           (rightBaseTop.dx + rightBaseBottom.dx) / 2,
//           (rightBaseTop.dy + rightBaseBottom.dy) / 2,
//         );

//         final rightSmallApex = scalePoint(rightApex, rightBaseCenter, scale);
//         final rightSmallBaseTop = scalePoint(
//           rightBaseTop,
//           rightBaseCenter,
//           scale,
//         );
//         final rightSmallBaseBottom = scalePoint(
//           rightBaseBottom,
//           rightBaseCenter,
//           scale,
//         );

//         final rightSmallPath = Path()
//           ..moveTo(rightSmallApex.dx, rightSmallApex.dy)
//           ..lineTo(rightSmallBaseTop.dx, rightSmallBaseTop.dy)
//           ..lineTo(rightSmallBaseBottom.dx, rightSmallBaseBottom.dy)
//           ..close();

//         shapes.add(
//           ShapeData.path(
//             path: rightSmallPath,
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         return shapes;
//       case "custom4":
//         final rect = Rect.fromPoints(start, end);
//         final shapes = <ShapeData>[];

//         // الإطار الخارجي
//         shapes.add(
//           ShapeData.rect(
//             start: rect.topLeft,
//             end: rect.bottomRight,
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         final halfWidth = rect.width / 2;
//         final upperHeightForRect = rect.height * 0.25;

//         // المستطيلين في الأعلى
//         shapes.add(
//           ShapeData.rect(
//             start: rect.topLeft,
//             end: Offset(rect.left + halfWidth, rect.top + upperHeightForRect),
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         shapes.add(
//           ShapeData.rect(
//             start: Offset(rect.left + halfWidth, rect.top),
//             end: Offset(rect.right, rect.top + upperHeightForRect),
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         // مقاس السهمين
//         final arrowHeight = rect.height * 0.15;
//         final arrowWidth = rect.width * 0.60;

//         // المستوى الأفقي (في النص تقريباً)
//         // final arrowY = rect.center.dy;
//         final arrowY = rect.top + rect.height * 0.40;

//         // السهم المتجه لليسار
//         shapes.add(
//           ShapeData.arrow(
//             start: Offset(rect.center.dx + arrowWidth / 2, arrowY),
//             end: Offset(rect.center.dx - arrowWidth / 2, arrowY),
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         // السهم المتجه لليمين
//         shapes.add(
//           ShapeData.arrow(
//             start: Offset(
//               rect.center.dx - arrowWidth / 2,
//               arrowY + arrowHeight,
//             ),
//             end: Offset(rect.center.dx + arrowWidth / 2, arrowY + arrowHeight),
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         return shapes;

//       case "custom5":
//         final rect = Rect.fromPoints(start, end);
//         final shapes = <ShapeData>[];

//         // الإطار الخارجي
//         shapes.add(
//           ShapeData.rect(
//             start: rect.topLeft,
//             end: rect.bottomRight,
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         final halfWidth = rect.width / 2;
//         final lowerHeightForRect = rect.height * 0.25;

//         // المستطيلين في الأسفل (بدل الأعلى)
//         shapes.add(
//           ShapeData.rect(
//             start: Offset(rect.left, rect.bottom - lowerHeightForRect),
//             end: Offset(rect.left + halfWidth, rect.bottom),
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         shapes.add(
//           ShapeData.rect(
//             start: Offset(
//               rect.left + halfWidth,
//               rect.bottom - lowerHeightForRect,
//             ),
//             end: Offset(rect.right, rect.bottom),
//             color: color,
//             strokeWidth: strokeWidth,
//             filled: false,
//           ),
//         );

//         // مقاس السهمين
//         final arrowHeight = rect.height * 0.20;
//         final arrowHeightforbuttom = rect.height * 0.02;
//         final arrowWidth = rect.width * 0.60;

//         // نخليهم فوق النص
//         final arrowsTopY = rect.center.dy - arrowHeight;
//         final arrowsBottomY = rect.center.dy - arrowHeightforbuttom;
//         // final arrowsBottomY = rect.center.dy; // عند النص نفسه

//         // السهم المتجه لليسار (الأعلى)
//         shapes.add(
//           ShapeData.arrow(
//             start: Offset(rect.center.dx + arrowWidth / 2, arrowsTopY),
//             end: Offset(rect.center.dx - arrowWidth / 2, arrowsTopY),
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         // السهم المتجه لليمين (اللي تحتو على طول)
//         shapes.add(
//           ShapeData.arrow(
//             start: Offset(rect.center.dx - arrowWidth / 2, arrowsBottomY),
//             end: Offset(rect.center.dx + arrowWidth / 2, arrowsBottomY),
//             color: color,
//             strokeWidth: strokeWidth,
//           ),
//         );

//         return shapes;

//       default:
//         return [];
//     }
//   }
// }
