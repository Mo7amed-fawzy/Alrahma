import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';

class SketchPainter extends CustomPainter {
  final List<PathData> paths;
  final List<ShapeData> shapes;
  final List<TextData> texts;
  final Offset? startShape; // نقطة البداية للشكل الجاري
  final List<Offset>? currentShapePoints; // نقاط الشكل الجاري
  final Size originalSize;
  final DrawingCanvasCubit? cubit;
  final Offset offset;
  final double scale;

  SketchPainter({
    required this.paths,
    required this.shapes,
    required this.texts,
    required this.originalSize,
    this.cubit,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.startShape,
    this.currentShapePoints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final state = cubit?.state;

    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    canvas.scale(scale);

    // ---------------- Paths
    for (final pathData in paths) {
      if (pathData.points.isEmpty) continue;

      final paint = Paint()
        ..color = pathData.color
        ..strokeWidth = pathData.strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      path.moveTo(pathData.points[0].dx, pathData.points[0].dy);

      if (state?.straightLineEnabled == true && pathData.points.length >= 2) {
        path.lineTo(pathData.points.last.dx, pathData.points.last.dy);
      } else {
        for (var point in pathData.points.skip(1)) {
          path.lineTo(point.dx, point.dy);
        }
      }

      canvas.drawPath(path, paint);
    }

    // ---------------- Shapes النهائية
    for (final s in shapes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.strokeWidth
        ..style = s.filled ? PaintingStyle.fill : PaintingStyle.stroke;

      switch (s.type) {
        case "rect":
          if (s.start != null && s.end != null) {
            canvas.drawRect(Rect.fromPoints(s.start!, s.end!), paint);
          }
          break;
        case "circle":
          if (s.center != null && s.radius != null) {
            canvas.drawCircle(s.center!, s.radius!, paint);
          }
          break;
      }
    }

    // ---------------- رسم الشكل الجاري أثناء السحب
    if (startShape != null &&
        currentShapePoints != null &&
        currentShapePoints!.isNotEmpty &&
        (state?.tool == "rect" || state?.tool == "circle")) {
      final paint = Paint()
        ..color = state?.selectedColor ?? Colors.black
        ..strokeWidth = state?.strokeWidth ?? 2
        ..style = PaintingStyle.stroke;

      final start = startShape!;
      final end = currentShapePoints!.last;

      if (state!.tool == "rect") {
        canvas.drawRect(Rect.fromPoints(start, end), paint);
      } else if (state.tool == "circle") {
        final radius = (end - start).distance / 2;
        final center = Offset((start.dx + end.dx) / 2, (start.dy + end.dy) / 2);
        canvas.drawCircle(center, radius, paint);
      }
    }

    // ---------------- Texts
    for (final t in texts) {
      final textSpan = TextSpan(
        text: t.text,
        style: CustomTextStyles.cairoRegular18.copyWith(
          color: t.color, // اللون اللي يختاره المستخدم
          fontSize: t.fontSize, // الحجم اللي يحدده المستخدم
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center, // الافتراضي وسط
        textDirection: TextDirection.rtl, // RTL عشان العربي
      );

      textPainter.layout(minWidth: 0, maxWidth: 0.6.sw); // 60% من عرض الشاشة

      canvas.save();
      canvas.translate(t.position.dx, t.position.dy);

      // خلفية اختيارية لو حابب
      if (t.hasBackground == true) {
        final rect = Rect.fromLTWH(
          0,
          0,
          textPainter.width + 8.w,
          textPainter.height + 4.h,
        );

        final bgPaint = Paint()
          ..color = (t.backgroundColor ?? AppColors.lightGray.withOpacity(0.6));
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(6)),
          bgPaint,
        );
      }

      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.shapes != shapes ||
        oldDelegate.texts != texts ||
        oldDelegate.originalSize != originalSize ||
        oldDelegate.cubit?.state != cubit?.state ||
        oldDelegate.offset != offset ||
        oldDelegate.scale != scale ||
        oldDelegate.startShape != startShape ||
        oldDelegate.currentShapePoints != currentShapePoints;
  }
}
