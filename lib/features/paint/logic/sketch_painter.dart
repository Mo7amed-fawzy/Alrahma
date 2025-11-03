// sketch_painter.dart
import 'dart:io';
import 'package:alrahma/core/models/data/image_data.dart';
import 'package:alrahma/core/models/data/text_data.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/features/paint/shapes/logic/shape_factory.dart';
import 'package:alrahma/features/paint/shapes/logic/shape_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SketchPainter extends CustomPainter {
  final List<PathData> paths;
  final List<ShapeData> shapes;
  final List<TextData> texts;
  final List<ImageData> images; // kept for reference, but not drawn here
  final Offset? startShape; // نقطة البداية للشكل الجاري
  final List<Offset>? currentShapePoints; // نقاط الشكل الجاري
  final Size originalSize;
  final DrawingCanvasCubit? cubit;
  final Offset
  offset; // kept for API compatibility but NOT used to re-apply transform
  final double scale; // kept for compatibility

  SketchPainter({
    required this.paths,
    required this.shapes,
    required this.texts,
    this.images = const [],
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

    // IMPORTANT:
    // Do NOT apply canvas.translate(offset.dx, offset.dy) or canvas.scale(scale)
    // here because the caller (DrawingCanvasWidget) already wraps CustomPaint
    // in a Transform(...) that applies offset & scale.
    //
    // Painter will draw in the canvas coordinates **after** the Transform,
    // so just draw the paths/shapes using the coordinates in state.

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

    // ---------------- Shapes النهائية (المحفوظة في الـ state)
    for (final s in shapes) {
      final paint = Paint()
        ..color = s.color
        ..strokeWidth = s.strokeWidth
        ..style = s.filled ? PaintingStyle.fill : PaintingStyle.stroke;

      ShapePainter.drawShape(canvas, s, paint);
    }

    // ---------------- Images
    // لم نعُد نرسم الصور هنا لأن الصور تُعرض كـ Widgets (Image.file) داخل Stack.
    // هذا يمنع أي تعارض في إدارة native resources ومشاكل الـ peer collection.

    // ---------------- رسم الشكل الجاري أثناء السحب (LIVE PREVIEW)
    if (startShape != null &&
        currentShapePoints != null &&
        currentShapePoints!.isNotEmpty &&
        state != null) {
      final paint = Paint()
        ..color = state.selectedColor
        ..strokeWidth = state.strokeWidth
        ..style = PaintingStyle.stroke;

      final start = startShape!;
      final end = currentShapePoints!.last;

      final previewShapes = ShapeFactory.fromTool(
        tool: state.tool,
        start: start,
        end: end,
        color: paint.color,
        strokeWidth: paint.strokeWidth,
      );

      for (var s in previewShapes) {
        ShapePainter.drawShape(canvas, s, paint);
      }
    }

    // ---------------- Texts
    // لم نَرسم النصوص هنا أيضاً لأن النصوص تُعرض كـ Widgets قابلة للسحب في Stack.

    // ---------------- Texts (Drag & Drop)
    // for (final t in texts) {
    //   final textSpan = TextSpan(
    //     text: t.text,
    //     style: CustomTextStyles.cairoRegular18.copyWith(
    //       color: t.color,
    //       fontSize: t.fontSize,
    //     ),
    //   );

    //   final textPainter = TextPainter(
    //     text: textSpan,
    //     textAlign: TextAlign.center,
    //     textDirection: TextDirection.rtl,
    //   );

    //   textPainter.layout(minWidth: 0, maxWidth: 0.6.sw);

    //   canvas.save();
    //   canvas.translate(t.position.dx, t.position.dy);
    //   textPainter.paint(canvas, Offset.zero);
    //   canvas.restore();
    // }
  }

  @override
  bool shouldRepaint(SketchPainter oldDelegate) {
    // حافظ على المقارنات الأساسية؛ لكن لاحظ أن offset/scale ليست مستخدمة داخلياً الآن
    return oldDelegate.paths != paths ||
        oldDelegate.shapes != shapes ||
        oldDelegate.texts != texts ||
        oldDelegate.images != images ||
        oldDelegate.originalSize != originalSize ||
        oldDelegate.cubit?.state != cubit?.state ||
        oldDelegate.startShape != startShape ||
        oldDelegate.currentShapePoints != currentShapePoints;
  }
}
