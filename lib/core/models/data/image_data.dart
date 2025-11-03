import 'dart:convert';
import 'package:flutter/material.dart';

class ImageData {
  final String id;
  final String imagePath; // ممكن تبقى base64 أو مسار فايل
  final Offset position;
  final double width;
  final double height;

  ImageData({
    required this.id,
    required this.imagePath,
    required this.position,
    this.width = 100,
    this.height = 100,
  });

  // =========================
  // CopyWith method
  // =========================
  ImageData copyWith({
    String? id,
    String? imagePath,
    Offset? position,
    double? width,
    double? height,
  }) {
    return ImageData(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      position: position ?? this.position,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  // =========================
  // ID generator
  // =========================
  static String generateId() =>
      DateTime.now().microsecondsSinceEpoch.toString();

  // =========================
  // Map & JSON conversion
  // =========================
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'position': {'dx': position.dx, 'dy': position.dy},
      'width': width,
      'height': height,
    };
  }

  factory ImageData.fromMap(Map<String, dynamic> map) {
    return ImageData(
      id: map['id'] ?? generateId(),
      imagePath: map['imagePath'],
      position: Offset(map['position']['dx'], map['position']['dy']),
      width: (map['width'] ?? 100).toDouble(),
      height: (map['height'] ?? 100).toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ImageData.fromJson(String source) =>
      ImageData.fromMap(json.decode(source));

  // =========================
  // Parse list of images from JSON string
  // =========================
  static List<ImageData> parseImages(String? dataJson) {
    if (dataJson == null) return [];
    final map = json.decode(dataJson);
    if (map['images'] == null) return [];
    return List<ImageData>.from(map['images'].map((e) => ImageData.fromMap(e)));
  }
}
