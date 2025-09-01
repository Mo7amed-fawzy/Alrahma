import 'package:flutter/material.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/models/project_model.dart';

class DrawingCanvasState {
  final List<ProjectModel> projects;
  final String selectedProjectId;

  // الرسم الحالي
  final List<PathData> currentPaths; // كل PathData = خط/مسار
  final List<ShapeData> shapes; // كل الأشكال الهندسية
  final List<TextData> textData; // كل النصوص
  final Color selectedColor;
  final double strokeWidth;
  final String tool; // freehand, line, rect, circle, text
  final bool straightLineEnabled;

  // التاريخ للتراجع / الإعادة
  final List<DrawingAction> history;
  final List<DrawingAction> redoHistory;

  // كل الرسومات الكاملة المرتبطة بالمشاريع
  final List<DrawingModel> drawings;
  final int? selectedTextIndex;

  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isHandTool; // ✅ أضفنا الخاصية الجديدة

  DrawingCanvasState({
    required this.projects,
    required this.selectedProjectId,
    this.currentPaths = const [],
    this.shapes = const [],
    this.textData = const [],
    this.selectedColor = Colors.black,
    this.strokeWidth = 2.0,
    this.tool = "freehand",
    this.straightLineEnabled = false,
    this.history = const [],
    this.redoHistory = const [],
    this.drawings = const [],
    this.selectedTextIndex,
    this.isHandTool = false, // افتراضي false

    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  DrawingCanvasState copyWith({
    List<ProjectModel>? projects,
    String? selectedProjectId,
    List<PathData>? currentPaths,
    List<ShapeData>? shapes,
    List<TextData>? textData,
    Color? selectedColor,
    double? strokeWidth,
    String? tool,
    bool? straightLineEnabled,
    List<DrawingAction>? history,
    List<DrawingAction>? redoHistory,
    List<DrawingModel>? drawings,
    int? selectedTextIndex, // ✅
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isHandTool, // ✅ دعم copyWith
  }) {
    return DrawingCanvasState(
      projects: projects ?? this.projects,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
      currentPaths: currentPaths ?? this.currentPaths,
      shapes: shapes ?? this.shapes,
      textData: textData ?? this.textData,
      selectedColor: selectedColor ?? this.selectedColor,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      tool: tool ?? this.tool,
      straightLineEnabled: straightLineEnabled ?? this.straightLineEnabled,
      history: history ?? this.history,
      redoHistory: redoHistory ?? this.redoHistory,
      drawings: drawings ?? this.drawings,
      selectedTextIndex: selectedTextIndex ?? this.selectedTextIndex, // ✅
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(), // ✅ يتحدث عند أي تعديل
      isHandTool: isHandTool ?? this.isHandTool,
    );
  }
}

/// نموذج يمثل أي حركة رسم (خط، شكل، نص) للتراجع / الإعادة
class DrawingAction {
  final String type; // "path", "shape", "text", "update_text", ...
  final dynamic data; // PathData / ShapeData / TextData
  final dynamic previousData; // optional

  DrawingAction({required this.type, required this.data, this.previousData});
}
