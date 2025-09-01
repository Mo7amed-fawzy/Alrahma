import 'dart:convert';
import 'package:flutter/material.dart';

/// =======================
/// Base Models
/// =======================

class PathData {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  PathData({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  Map<String, dynamic> toMap() {
    return {
      'points': points.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
    };
  }

  factory PathData.fromMap(Map<String, dynamic> map) {
    return PathData(
      points: List<Offset>.from(
        (map['points'] as List).map((e) => Offset(e['dx'], e['dy'])),
      ),
      color: Color(map['color']),
      strokeWidth: map['strokeWidth'],
    );
  }
}

class ShapeData {
  final String type; // "rect" أو "circle"
  final Color color;
  final double strokeWidth;
  final bool filled;

  // للـ rectangle
  final Offset? start;
  final Offset? end;

  // للـ circle
  final Offset? center;
  final double? radius;

  ShapeData.rect({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
  }) : type = "rect",
       center = null,
       radius = null;

  ShapeData.circle({
    required this.center,
    required this.radius,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
  }) : type = "circle",
       start = null,
       end = null;

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'filled': filled,
      'start': start != null ? {'dx': start!.dx, 'dy': start!.dy} : null,
      'end': end != null ? {'dx': end!.dx, 'dy': end!.dy} : null,
      'center': center != null ? {'dx': center!.dx, 'dy': center!.dy} : null,
      'radius': radius,
    };
  }

  factory ShapeData.fromMap(Map<String, dynamic> map) {
    final type = map['type'];
    switch (type) {
      case "rect":
        return ShapeData.rect(
          start: Offset(map['start']['dx'], map['start']['dy']),
          end: Offset(map['end']['dx'], map['end']['dy']),
          color: Color(map['color']),
          strokeWidth: map['strokeWidth'] ?? 2.0,
          filled: map['filled'] ?? false,
        );
      case "circle":
        return ShapeData.circle(
          center: Offset(map['center']['dx'], map['center']['dy']),
          radius: map['radius'],
          color: Color(map['color']),
          strokeWidth: map['strokeWidth'] ?? 2.0,
          filled: map['filled'] ?? false,
        );
      default:
        throw Exception("Unknown shape type $type");
    }
  }
}

class TextData {
  final String id; // ✅ معرف فريد
  final String text;
  final Offset position;
  final double fontSize;
  final Color color;

  /// 🎨 لون الخلفية (اختياري)
  final Color? backgroundColor;

  /// 📌 هل ليه خلفية ولا لا
  final bool hasBackground;

  TextData({
    required this.id, // ✅ لازم نوفره أو نولّده
    required this.text,
    required this.position,
    required this.fontSize,
    required this.color,
    this.backgroundColor,
    this.hasBackground = false,
  });

  /// مولّد بسيط للـ id
  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  /// 🔄 للتحويل إلى Map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // ✅
      'text': text,
      'position': {'dx': position.dx, 'dy': position.dy},
      'fontSize': fontSize,
      'color': color.value,
      'backgroundColor': backgroundColor?.value,
      'hasBackground': hasBackground,
    };
  }

  /// 🔄 للتحويل من Map (مع دعم البيانات القديمة بدون id)
  factory TextData.fromMap(Map<String, dynamic> map) {
    return TextData(
      id: (map['id'] ?? TextData.generateId()).toString(), // ✅ fallback
      text: map['text'] ?? '',
      position: Offset(map['position']['dx'], map['position']['dy']),
      fontSize: (map['fontSize'] ?? 18).toDouble(),
      color: Color(map['color'] ?? Colors.black.value),
      backgroundColor: map['backgroundColor'] != null
          ? Color(map['backgroundColor'])
          : null,
      hasBackground: map['hasBackground'] ?? false,
    );
  }

  /// 📦 JSON
  String toJson() => json.encode(toMap());
  factory TextData.fromJson(String source) =>
      TextData.fromMap(json.decode(source));

  /// 🛠 إنشاء نسخة جديدة مع تغييرات
  TextData copyWith({
    String? id,
    String? text,
    Offset? position,
    double? fontSize,
    Color? color,
    Color? backgroundColor,
    bool? hasBackground,
  }) {
    return TextData(
      id: id ?? this.id,
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      hasBackground: hasBackground ?? this.hasBackground,
    );
  }

  @override
  String toString() {
    return 'TextData(id: $id, text: $text, position: $position, fontSize: $fontSize, color: $color, backgroundColor: $backgroundColor, hasBackground: $hasBackground)';
  }
}

/// =======================
/// Hybrid Optimized DrawingModel
/// =======================
class DrawingModel {
  final String id;
  final String projectId;
  final String title;

  // النسخة القديمة
  final String? dataJson;

  // النسخة الجديدة
  final List<PathData> paths;
  final List<ShapeData> shapes;
  final List<TextData> texts;

  // خصائص الرسم
  final Color selectedColor;
  final double strokeWidth;
  final String tool;

  final DateTime createdAt; // 🟢 أضفنا التاريخ
  DateTime updatedAt; // 🟢 آخر تعديل

  DrawingModel({
    required this.id,
    required this.projectId,
    required this.title,
    this.dataJson,
    List<PathData>? paths,
    List<ShapeData>? shapes,
    List<TextData>? texts,
    this.selectedColor = Colors.black,
    this.strokeWidth = 2.0,
    this.tool = "freehand",
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : paths = paths ?? _parsePaths(dataJson),
       shapes = shapes ?? _parseShapes(dataJson),
       texts = texts ?? _parseTexts(dataJson),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// -------- copyWith --------
  DrawingModel copyWith({
    String? id,
    String? projectId,
    String? title,
    String? dataJson,
    List<PathData>? paths,
    List<ShapeData>? shapes,
    List<TextData>? texts,
    Color? selectedColor,
    double? strokeWidth,
    String? tool,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DrawingModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      dataJson: dataJson ?? this.dataJson,
      paths: paths ?? this.paths,
      shapes: shapes ?? this.shapes,
      texts: texts ?? this.texts,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      tool: tool ?? this.tool,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // 🟢 كل مرة copyWith = تعديل جديد
    );
  }

  /// -------- toMap / fromMap --------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'title': title,
      'paths': paths.map((e) => e.toMap()).toList(),
      'shapes': shapes.map((e) => e.toMap()).toList(),
      'texts': texts.map((e) => e.toMap()).toList(),
      'selectedColor': selectedColor.value,
      'strokeWidth': strokeWidth,
      'tool': tool,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DrawingModel.fromMap(Map<String, dynamic> map) {
    return DrawingModel(
      id: map['id'],
      projectId: map['projectId'],
      title: map['title'] ?? "بدون عنوان",

      // لو موجود paths/shapes/texts بشكل مباشر → خدهم
      // لو لأ → fallback للـ dataJson
      paths: map['paths'] != null
          ? List<PathData>.from(map['paths'].map((e) => PathData.fromMap(e)))
          : _parsePaths(map['dataJson']),
      shapes: map['shapes'] != null
          ? List<ShapeData>.from(map['shapes'].map((e) => ShapeData.fromMap(e)))
          : _parseShapes(map['dataJson']),
      texts: map['texts'] != null
          ? List<TextData>.from(map['texts'].map((e) => TextData.fromMap(e)))
          : _parseTexts(map['dataJson']),

      dataJson: map['dataJson'], // عشان تفضل تدعم النسخة القديمة
      selectedColor: map['selectedColor'] != null
          ? Color(map['selectedColor'])
          : Colors.black,
      strokeWidth: map['strokeWidth']?.toDouble() ?? 2.0,
      tool: map['tool'] ?? "freehand",
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : DateTime.now(),
    );
  }

  /// -------- JSON --------
  String toJson() => json.encode(toMap());
  factory DrawingModel.fromJson(String source) =>
      DrawingModel.fromMap(json.decode(source));

  /// -------- Helpers لتحويل JSON القديم إلى Objects --------
  static List<PathData> _parsePaths(String? dataJson) {
    if (dataJson == null) return [];
    final map = json.decode(dataJson);
    if (map['paths'] == null) return [];
    return List<PathData>.from(map['paths'].map((e) => PathData.fromMap(e)));
  }

  static List<ShapeData> _parseShapes(String? dataJson) {
    if (dataJson == null) return [];
    final map = json.decode(dataJson);
    if (map['shapes'] == null) return [];
    return List<ShapeData>.from(map['shapes'].map((e) => ShapeData.fromMap(e)));
  }

  static List<TextData> _parseTexts(String? dataJson) {
    if (dataJson == null) return [];
    final map = json.decode(dataJson);
    if (map['texts'] == null) return [];
    return List<TextData>.from(map['texts'].map((e) => TextData.fromMap(e)));
  }
}
