import 'package:flutter/material.dart';
import 'package:tabea/features/paint/model/models.dart';

/// نسخة محسنة من SketchPainter تدعم PathData و ShapeData
class SketchPainter extends CustomPainter {
  final List<PathData> paths;
  final List<ShapeData> shapes;
  final List<Map<String, dynamic>> texts;

  SketchPainter({
    this.paths = const [],
    this.shapes = const [],
    this.texts = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 🎨 رسم الخطوط الحرة (paths)
    for (var p in paths) {
      if (p.path != null) {
        final paint = Paint()
          ..color = p.color
          ..strokeWidth = p.width
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        canvas.drawPath(p.path!, paint);
      }
    }

    // 🔲 رسم الأشكال
    for (var s in shapes) {
      final shapePaint = Paint()
        ..color = s.color
        ..strokeWidth = s.strokeWidth
        ..style = PaintingStyle.stroke;

      switch (s.type) {
        case ShapeType.rectangle:
          if (s.rect != null) canvas.drawRect(s.rect!, shapePaint);
          break;
        case ShapeType.circle:
          if (s.center != null && s.radius != null) {
            canvas.drawCircle(s.center!, s.radius!, shapePaint);
          }
          break;
        case ShapeType.oval:
          if (s.rect != null) canvas.drawOval(s.rect!, shapePaint);
          break;
      }
    }

    // 📝 رسم النصوص
    for (var t in texts) {
      final String text = t['text'] ?? '';
      final double fontSize = (t['size'] ?? 16.0).toDouble();
      final Color color = t['color'] is Color
          ? t['color'] as Color
          : Color(t['color'] ?? 0xFF000000);
      final Offset pos = t['position'] is Offset
          ? t['position'] as Offset
          : Offset(
              (t['position']?['dx'] ?? 0).toDouble(),
              (t['position']?['dy'] ?? 0).toDouble(),
            );

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
      );

      textPainter.layout();
      textPainter.paint(canvas, pos);
    }
  }

  @override
  bool shouldRepaint(covariant SketchPainter oldDelegate) {
    return oldDelegate.paths != paths ||
        oldDelegate.shapes != shapes ||
        oldDelegate.texts != texts;
  }
}
