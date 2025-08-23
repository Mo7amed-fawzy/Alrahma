import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:tabea/features/paint/model/models.dart';

class DrawingModel {
  String id;
  String projectId;
  String drawingData; // JSON encoded freehand paths or SVG
  DateTime createdAt;

  DrawingModel({
    required this.id,
    required this.projectId,
    required this.drawingData,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'drawingData': drawingData,
    'createdAt': createdAt.toIso8601String(),
  };

  factory DrawingModel.fromJson(Map<String, dynamic> json) => DrawingModel(
    id: json['id'],
    projectId: json['projectId'],
    drawingData: json['drawingData'],
    createdAt: DateTime.parse(json['createdAt']),
  );

  // -------------------------
  // Helpers for safe parsing
  // -------------------------
  static double _toDouble(dynamic v, [double fallback = 0.0]) {
    if (v == null) return fallback;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? fallback;
    return fallback;
  }

  static Color _parseColor(dynamic val) {
    if (val == null) return const Color(0xFF000000);
    if (val is int) return Color(val);
    if (val is String) {
      var s = val.replaceAll('#', '');
      if (s.length == 6) s = 'FF' + s;
      if (s.length == 8) {
        try {
          return Color(int.parse('0x$s'));
        } catch (_) {}
      }
    }
    return const Color(0xFF000000);
  }

  static ShapeType _parseShapeType(dynamic v) {
    if (v == null) return ShapeType.rectangle;
    if (v is int) {
      if (v >= 0 && v < ShapeType.values.length) return ShapeType.values[v];
      return ShapeType.rectangle;
    }
    if (v is String) {
      final s = v.toLowerCase();
      if (s.contains('rect')) return ShapeType.rectangle;
      if (s.contains('circle')) return ShapeType.circle;
      if (s.contains('oval')) return ShapeType.oval;
    }
    return ShapeType.rectangle;
  }

  // -------------------------
  // Parsers that tolerate missing fields
  // -------------------------
  List<PathData> get paths {
    try {
      final decoded = jsonDecode(drawingData);
      if (decoded == null || decoded is! Map) return [];
      final raw = decoded['paths'];
      if (raw == null || raw is! List) return [];

      return raw.map<PathData>((eRaw) {
        final e = eRaw is Map ? eRaw : {};
        final color = _parseColor(e['color']);
        final width = _toDouble(e['width'], 4.0);

        Path? path;
        if (e['points'] is List && (e['points'] as List).isNotEmpty) {
          try {
            final pts = e['points'] as List;
            path = Path();
            final first = pts.first;
            path.moveTo(_toDouble(first['dx']), _toDouble(first['dy']));
            for (var p in pts.skip(1)) {
              path.lineTo(_toDouble(p['dx']), _toDouble(p['dy']));
            }
          } catch (_) {
            path = null;
          }
        }

        return PathData(path: path ?? Path(), color: color, width: width);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  List<ShapeData> get shapes {
    try {
      final decoded = jsonDecode(drawingData);
      if (decoded == null || decoded is! Map) return [];
      final raw = decoded['shapes'];
      if (raw == null || raw is! List) return [];

      return (raw).map<ShapeData>((eRaw) {
        final e = eRaw is Map ? eRaw : {};
        final type = _parseShapeType(e['type']);

        Rect? rect;
        if (e['rect'] is Map) {
          final r = e['rect'] as Map;
          final l = r['left'];
          final t = r['top'];
          final w = r['width'];
          final h = r['height'];
          if (l != null && t != null && w != null && h != null) {
            rect = Rect.fromLTWH(
              _toDouble(l),
              _toDouble(t),
              _toDouble(w),
              _toDouble(h),
            );
          }
        }

        Offset? center;
        if (e['center'] is Map) {
          final c = e['center'] as Map;
          if (c['dx'] != null && c['dy'] != null) {
            center = Offset(_toDouble(c['dx']), _toDouble(c['dy']));
          }
        }

        final radius = e['radius'] == null ? null : _toDouble(e['radius'], 0.0);
        final color = _parseColor(e['color']);
        final stroke = _toDouble(e['strokeWidth'], 2.0);

        return ShapeData(
          type: type,
          rect: rect,
          center: center,
          radius: radius,
          color: color,
          strokeWidth: stroke,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> get texts {
    try {
      final decoded = jsonDecode(drawingData);
      if (decoded == null || decoded is! Map) return [];
      final raw = decoded['texts'];
      if (raw == null || raw is! List) return [];

      return (raw).map<Map<String, dynamic>>((tRaw) {
        final t = tRaw is Map
            ? Map<String, dynamic>.from(tRaw)
            : <String, dynamic>{};

        // position => Offset
        if (t['position'] is Map) {
          final p = t['position'] as Map;
          final dx = _toDouble(p['dx'], 0.0);
          final dy = _toDouble(p['dy'], 0.0);
          t['position'] = Offset(dx, dy);
        } else {
          t['position'] = const Offset(0, 0);
        }

        // size
        t['size'] = _toDouble(t['size'], 16.0);

        // color
        t['color'] = _parseColor(t['color']);

        // text string fallback
        t['text'] = (t['text'] ?? '').toString();

        return t;
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
