import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/features/paint/shapes/custom/circle_shape.dart';
import 'package:alrahma/features/paint/shapes/custom/door_shape.dart';
import 'package:alrahma/features/paint/shapes/custom/rect_shape.dart';
import 'package:flutter/material.dart';
import '../custom/window_shape.dart';
import '../custom_shapes.dart';

class ShapeFactory {
  static List<ShapeData> fromTool({
    required String tool,
    required Offset start,
    required Offset end,
    required Color color,
    required double strokeWidth,
  }) {
    switch (tool) {
      case "rect":
        return [
          RectShape.fromPoints(
            start: start,
            end: end,
            color: color,
            strokeWidth: strokeWidth,
          ),
        ];
      case "circle":
        return [
          CircleShape.fromPoints(
            start: start,
            end: end,
            color: color,
            strokeWidth: strokeWidth,
          ),
        ];
      case "door":
        return DoorShape.create(
          topLeft: start,
          size: Size(end.dx - start.dx, end.dy - start.dy),
          color: color,
          strokeWidth: strokeWidth,
        );
      case "window":
        return WindowShape.create(
          topLeft: start,
          size: Size(end.dx - start.dx, end.dy - start.dy),
          color: color,
          strokeWidth: strokeWidth,
        );
      default:
        return CustomShapes.fromTool(tool, start, end, color, strokeWidth);
    }
  }
}
