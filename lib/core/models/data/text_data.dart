import 'dart:convert';

import 'package:flutter/material.dart';

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
