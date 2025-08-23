import 'package:flutter/material.dart';
import 'package:tabea/core/models/drawing_model.dart';
import 'package:tabea/core/models/project_model.dart';
import 'package:tabea/features/paint/model/models.dart'; // ShapeData

class DrawingCanvasState {
  final List<ProjectModel> projects;
  final String selectedProjectId;
  final List<Map<String, dynamic>> paths;
  final List<Offset> currentPath;
  final Color selectedColor;
  final double strokeWidth;
  final String tool; // freehand, line, rect, circle, text
  final List<Map<String, dynamic>> history;
  final List<Map<String, dynamic>> redoHistory;

  final bool straightLineEnabled;
  final List<Map<String, dynamic>> texts;

  // ✅ أضف هذا
  final List<ShapeData> shapes;
  final List<DrawingModel> drawings;
  DrawingCanvasState({
    required this.projects,
    required this.selectedProjectId,
    this.paths = const [],
    this.currentPath = const [],
    this.history = const [],
    this.redoHistory = const [],
    this.selectedColor = Colors.black,
    this.strokeWidth = 2.0,
    this.tool = "freehand",
    this.straightLineEnabled = false,
    this.texts = const [],
    this.shapes = const [], // ✅ الافتراضي
    this.drawings = const [], // ✅ الافتراضي
  });

  DrawingCanvasState copyWith({
    List<ProjectModel>? projects,
    String? selectedProjectId,
    List<Map<String, dynamic>>? paths,
    List<Map<String, dynamic>>? history,
    List<Map<String, dynamic>>? redoHistory,
    List<Offset>? currentPath,
    Color? selectedColor,
    double? strokeWidth,
    String? tool,
    bool? straightLineEnabled,
    List<Map<String, dynamic>>? texts,
    List<ShapeData>? shapes, // ✅ أضف هذا
    List<DrawingModel>? drawings, // ✅ أضف هذا
  }) {
    return DrawingCanvasState(
      projects: projects ?? this.projects,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      paths: paths ?? this.paths,
      history: history ?? this.history,
      redoHistory: redoHistory ?? this.redoHistory,
      currentPath: currentPath ?? this.currentPath,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      tool: tool ?? this.tool,
      straightLineEnabled: straightLineEnabled ?? this.straightLineEnabled,
      texts: texts ?? this.texts,
      shapes: shapes ?? this.shapes, // ✅ هنا
      drawings: drawings ?? this.drawings, // ✅ هنا
    );
  }
}
