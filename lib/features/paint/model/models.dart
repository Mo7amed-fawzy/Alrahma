import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PathData {
  final Path? path;
  final Color color;
  final double width;

  PathData({required this.path, required this.color, required this.width});

  factory PathData.fromJson(Map<String, dynamic> json) {
    return PathData(
      path: Path(), // ⚠️ لازم طريقة لتحويل points لـ Path
      color: Color(json['color'] as int),
      width: (json['width'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'color': color.value,
    'width': width,
    // ⚠️ هنا لازم تحفظ points مش Path مباشر
  };

  static fromMap(Map<String, dynamic> e) {}
}

enum ShapeType { rectangle, circle, oval }

class ShapeData {
  final ShapeType type;
  final Rect? rect;
  final Offset? center;
  final double? radius;
  final Color color;
  final double strokeWidth;

  ShapeData({
    required this.type,
    this.rect,
    this.center,
    this.radius,
    required this.color,
    required this.strokeWidth,
  });

  // 🔹 تحويل من Map
  factory ShapeData.fromMap(Map<String, dynamic> map) {
    ShapeType parseType(String t) {
      switch (t) {
        case 'rectangle':
          return ShapeType.rectangle;
        case 'circle':
          return ShapeType.circle;
        case 'oval':
          return ShapeType.oval;
        default:
          return ShapeType.rectangle;
      }
    }

    return ShapeData(
      type: parseType(map['type'] ?? 'rectangle'),
      rect: map['rect'] != null
          ? Rect.fromLTWH(
              (map['rect']['left'] ?? 0).toDouble(),
              (map['rect']['top'] ?? 0).toDouble(),
              (map['rect']['width'] ?? 0).toDouble(),
              (map['rect']['height'] ?? 0).toDouble(),
            )
          : null,
      center: map['center'] != null
          ? Offset(
              (map['center']['dx'] ?? 0).toDouble(),
              (map['center']['dy'] ?? 0).toDouble(),
            )
          : null,
      radius: map['radius']?.toDouble(),
      color: Color(map['color'] ?? 0xFF000000),
      strokeWidth: map['strokeWidth']?.toDouble() ?? 2.0,
    );
  }
}
