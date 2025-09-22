import 'package:alrahma/core/models/drawing_model.dart';
import 'package:flutter/material.dart';

class ShapePainter {
  static void drawShape(Canvas canvas, ShapeData shape, Paint paint) {
    switch (shape.type) {
      case "rect":
        if (shape.start != null && shape.end != null) {
          canvas.drawRect(Rect.fromPoints(shape.start!, shape.end!), paint);
        }
        break;

      case "circle":
        if (shape.center != null && shape.radius != null) {
          if (shape.filled) {
            final fillPaint = Paint()
              ..color = shape.color
              ..style = PaintingStyle.fill;
            canvas.drawCircle(shape.center!, shape.radius!, fillPaint);

            if (shape.strokeWidth > 0) {
              final strokePaint = Paint()
                ..color = shape.color
                ..style = PaintingStyle.stroke
                ..strokeWidth = shape.strokeWidth;
              canvas.drawCircle(shape.center!, shape.radius!, strokePaint);
            }
          } else {
            canvas.drawCircle(shape.center!, shape.radius!, paint);
          }
        }
        break;

      case "path":
      case "triangle":
      case "arrow":
        if (shape.path != null) {
          canvas.drawPath(shape.path!, paint);
        }
        break;

      default:
        break;
    }
  }
}
