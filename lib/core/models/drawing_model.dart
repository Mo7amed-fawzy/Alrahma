import 'dart:convert';
import 'dart:math';
import 'package:alrahma/core/models/data/image_data.dart';
import 'package:alrahma/core/models/data/text_data.dart';
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
  final String type;
  final Offset? start;
  final Offset? end;
  final Offset? center;
  final double? radius;
  final Color color;
  final double strokeWidth;
  final bool filled;

  final Path? path;
  final List<Offset>? points;

  // ================= RECTANGLE =================
  ShapeData.rect({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
  }) : type = "rect",
       center = null,
       radius = null,
       path = null,
       points = null;

  // ================= CIRCLE =================
  ShapeData.circle({
    required this.center,
    required this.radius,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
  }) : type = "circle",
       start = null,
       end = null,
       path = null,
       points = null;

  // ================= TRIANGLE =================
  ShapeData.triangle({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
  }) : type = "triangle",
       center = null,
       radius = null,
       path = _buildTrianglePath(start!, end!),
       points = _extractPoints(_buildTrianglePath(start, end));

  // ================= ARROW =================
  // ================= ARROW =================
  ShapeData.arrow({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
  }) : type = "arrow",
       center = null,
       radius = null,
       path = _buildArrowPathTriangle(start!, end!), // 👈 هنا
       points = _extractPoints(_buildArrowPathTriangle(start, end));

  // // النسخة القديمة (موجودة زي ما هي)
  // static Path _buildArrowPath(Offset start, Offset end) {
  //   final path = Path();
  //   // خط السهم
  //   path.moveTo(start.dx, start.dy);
  //   path.lineTo(end.dx, end.dy);

  //   // رأس السهم (ثابتة يسار/يمين)
  //   final arrowSize = 10;
  //   path.moveTo(end.dx, end.dy);
  //   path.lineTo(end.dx - arrowSize, end.dy - arrowSize);
  //   path.moveTo(end.dx, end.dy);
  //   path.lineTo(end.dx - arrowSize, end.dy + arrowSize);

  //   return path;
  // }

  // نسخة جديدة بتلف الراس حسب الاتجاه
  // نسخة جديدة لسهم برأس مثلث
  static Path _buildArrowPathTriangle(Offset start, Offset end) {
    final path = Path();
    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    final arrowLength = 14.0; // طول راس السهم
    final arrowWidth = 10.0; // عرض راس السهم

    final angle = atan2(end.dy - start.dy, end.dx - start.dx);

    // نقطتين لقاعدة المثلث
    final p1 = Offset(
      end.dx - arrowLength * cos(angle) - arrowWidth * sin(angle),
      end.dy - arrowLength * sin(angle) + arrowWidth * cos(angle),
    );

    final p2 = Offset(
      end.dx - arrowLength * cos(angle) + arrowWidth * sin(angle),
      end.dy - arrowLength * sin(angle) - arrowWidth * cos(angle),
    );

    // نرسم المثلث
    path.moveTo(end.dx, end.dy);
    path.lineTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.close();

    return path;
  }

  // ================= PATH =================
  ShapeData.path({
    required Path path,
    required this.color,
    this.strokeWidth = 2.0,
    this.filled = false,
  }) : type = "path",
       start = null,
       end = null,
       center = null,
       radius = null,
       path = path,
       points = _extractPoints(path);

  // -------- Helpers --------
  static Path _buildTrianglePath(Offset start, Offset end) {
    final path = Path();
    final p1 = Offset((start.dx + end.dx) / 2, start.dy); // top middle
    final p2 = Offset(start.dx, end.dy); // bottom left
    final p3 = Offset(end.dx, end.dy); // bottom right
    path.moveTo(p1.dx, p1.dy);
    path.lineTo(p2.dx, p2.dy);
    path.lineTo(p3.dx, p3.dy);
    path.close();
    return path;
  }

  // static Path _buildArrowPath(Offset start, Offset end) {
  //   final path = Path();

  //   // الخط الرئيسي
  //   path.moveTo(start.dx, start.dy);
  //   path.lineTo(end.dx, end.dy);

  //   // اتجاه السهم (الزاوية)
  //   final arrowSize = 12.0;
  //   final angle = atan2(end.dy - start.dy, end.dx - start.dx);

  //   // النقطتين بتوع رأس السهم
  //   final arrowP1 = Offset(
  //     end.dx - arrowSize * cos(angle - pi / 6),
  //     end.dy - arrowSize * sin(angle - pi / 6),
  //   );
  //   final arrowP2 = Offset(
  //     end.dx - arrowSize * cos(angle + pi / 6),
  //     end.dy - arrowSize * sin(angle + pi / 6),
  //   );

  //   // رأس السهم
  //   path.moveTo(end.dx, end.dy);
  //   path.lineTo(arrowP1.dx, arrowP1.dy);
  //   path.lineTo(arrowP2.dx, arrowP2.dy);
  //   path.close();

  //   return path;
  // }

  static List<Offset> _extractPoints(Path path) {
    final metrics = path.computeMetrics().toList();
    final points = <Offset>[];
    for (var metric in metrics) {
      final length = metric.length;
      for (double d = 0.0; d < length; d += 5.0) {
        final pos = metric.getTangentForOffset(d)!.position;
        points.add(pos);
      }
    }
    return points;
  }

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
      // ⚠️ الـ Path مش هينفع يتخزن بسهولة → مؤقتاً نخليه null
      'points': points?.map((e) => {'dx': e.dx, 'dy': e.dy}).toList(),
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
      case "path":
        final pts =
            (map['points'] as List?)
                ?.map((e) => Offset(e['dx'], e['dy']))
                .toList() ??
            [];
        final rebuiltPath = Path();
        if (pts.isNotEmpty) {
          rebuiltPath.moveTo(pts.first.dx, pts.first.dy);
          for (var p in pts.skip(1)) {
            rebuiltPath.lineTo(p.dx, p.dy);
          }
          rebuiltPath.close();
        }
        return ShapeData.path(
          path: rebuiltPath,
          color: Color(map['color']),
          strokeWidth: map['strokeWidth'] ?? 2.0,
          filled: map['filled'] ?? false,
        );

      case "triangle":
        return ShapeData.triangle(
          start: Offset(map['start']['dx'], map['start']['dy']),
          end: Offset(map['end']['dx'], map['end']['dy']),
          color: Color(map['color']),
          strokeWidth: map['strokeWidth'] ?? 2.0,
          filled: map['filled'] ?? false,
        );

      case "arrow":
        return ShapeData.arrow(
          start: Offset(map['start']['dx'], map['start']['dy']),
          end: Offset(map['end']['dx'], map['end']['dy']),
          color: Color(map['color']),
          strokeWidth: map['strokeWidth'] ?? 2.0,
          filled: map['filled'] ?? false,
        );

      default:
        throw Exception("Unknown shape type: $type");
    }
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
  final List<ImageData> images; // 🟢 جديد

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
    List<ImageData>? images,
  }) : images = images ?? ImageData.parseImages(dataJson),
       paths = paths ?? _parsePaths(dataJson),
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
    List<ImageData>? images, // 🟢 جديد
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
      images: images ?? this.images,
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
      'images': images.map((e) => e.toMap()).toList(),
    };
  }

  factory DrawingModel.fromMap(Map<String, dynamic> map) {
    List<ImageData> imagesList = [];
    final imagesRaw = map['images'];
    if (imagesRaw != null) {
      if (imagesRaw is String) {
        try {
          final decoded = json.decode(imagesRaw);
          imagesList = List<ImageData>.from(
            decoded.map((e) => ImageData.fromMap(e)),
          );
        } catch (_) {
          imagesList = [];
        }
      } else if (imagesRaw is List) {
        imagesList = List<ImageData>.from(
          imagesRaw.map((e) => ImageData.fromMap(e)),
        );
      }
    }

    return DrawingModel(
      id: map['id'],
      projectId: map['projectId'],
      title: map['title'] ?? "بدون عنوان",
      dataJson: map['dataJson'],
      paths: map['paths'] != null
          ? List<PathData>.from(map['paths'].map((e) => PathData.fromMap(e)))
          : _parsePaths(map['dataJson']),
      shapes: map['shapes'] != null
          ? List<ShapeData>.from(map['shapes'].map((e) => ShapeData.fromMap(e)))
          : _parseShapes(map['dataJson']),
      texts: map['texts'] != null
          ? List<TextData>.from(map['texts'].map((e) => TextData.fromMap(e)))
          : _parseTexts(map['dataJson']),
      images: imagesList,
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
