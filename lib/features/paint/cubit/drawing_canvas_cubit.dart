import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_state.dart';
import 'package:alrahma/features/paint/repository/drawing_repository.dart';

// بعمل فنكشن علشان اقدر اعدل علي الكلاسات المعايه منغير ما اعدل علي الاصلي
extension ListCopy<T> on List<T> {
  List<T> clone() => List<T>.from(this);
}

class DrawingCanvasCubit extends Cubit<DrawingCanvasState> {
  final DrawingRepository? repository;

  DrawingCanvasCubit({required List<ProjectModel> projects, this.repository})
    : super(
        DrawingCanvasState(
          projects: projects,
          selectedProjectId: "", // خليها فارغة
          tool: "freehand",
          straightLineEnabled: false,
          isHandTool: false,
        ),
      );

  /// -------------------------
  /// تغيير المشروع الحالي
  /// -------------------------
  void selectProject(String projectId) {
    emit(state.copyWith(selectedProjectId: projectId));
  }

  /// -------------------------
  /// تغيير أداة الرسم
  /// -------------------------
  void changeTool(String tool) {
    emit(
      state.copyWith(
        tool: tool,
        isHandTool: tool == "hand" ? state.isHandTool : false,
      ),
    );
    _autoSaveDrawing();
  }

  /// -------------------------
  /// تغيير اللون أو حجم الخط
  /// -------------------------
  void changeColor(Color color) {
    emit(state.copyWith(selectedColor: color));
    _autoSaveDrawing();
  }

  void changeStrokeWidth(double width) {
    emit(state.copyWith(strokeWidth: width));
    _autoSaveDrawing();
  }

  /// -------------------------
  /// إضافة PathData (خط/مسار)
  /// -------------------------
  void addPath(PathData path) {
    final updatedPaths = List<PathData>.from(state.currentPaths)..add(path);
    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(DrawingAction(type: "path", data: path));

    emit(
      state.copyWith(
        currentPaths: updatedPaths,
        history: updatedHistory,
        redoHistory: [],
      ),
    );

    _autoSaveDrawing(
      paths: updatedPaths,
      shapes: state.shapes,
      texts: state.textData,
    );
  }

  /// -------------------------
  /// إضافة Shape
  /// -------------------------
  void addShape(ShapeData shape) {
    final updatedShapes = List<ShapeData>.from(state.shapes)..add(shape);
    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(DrawingAction(type: "shape", data: shape));

    emit(
      state.copyWith(
        shapes: updatedShapes,
        history: updatedHistory,
        redoHistory: [],
      ),
    );

    _autoSaveDrawing(
      paths: state.currentPaths,
      shapes: updatedShapes,
      texts: state.textData,
    );
  }

  /// -------------------------
  /// إضافة نص جديد مع خصائصه (لون وحجم الخط)
  /// -------------------------
  void addText(
    String text, {
    Color? color,
    double? fontSize,
    Offset? position,
    Color? backgroundColor, // ✅ خلفية
    bool hasBackground = false, // ✅ هل فيه خلفية
  }) {
    final newText = TextData(
      id: TextData.generateId(), // ✅ ID مميز لكل نص
      text: text,
      color: color ?? state.selectedColor,
      fontSize: fontSize ?? state.strokeWidth * 4, // خليه أكبر من الخط العادي
      position: position ?? Offset.zero,
      backgroundColor: backgroundColor, // ✅ اضفنا الخلفية
      hasBackground: hasBackground, // ✅ اضفنا الفلاج
    );

    final updatedTexts = List<TextData>.from(state.textData)..add(newText);

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(DrawingAction(type: "text", data: newText));

    emit(
      state.copyWith(
        textData: updatedTexts,
        history: updatedHistory,
        redoHistory: [],
      ),
    );

    _autoSaveDrawing(
      paths: state.currentPaths,
      shapes: state.shapes,
      texts: updatedTexts,
    );
  }

  void updateTextBackground({
    required String textId,
    required bool hasBackground,
    Color? backgroundColor,
  }) {
    final texts = List<TextData>.from(state.textData);
    final index = texts.indexWhere((t) => t.id == textId);

    if (index == -1) return; // النص مش موجود

    final oldText = texts[index];
    final updated = oldText.copyWith(
      hasBackground: hasBackground,
      backgroundColor: backgroundColor ?? Colors.transparent,
    );

    texts[index] = updated;

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(
        DrawingAction(
          type: "update_text_background",
          data: updated,
          previousData: oldText,
        ),
      );

    emit(
      state.copyWith(textData: texts, history: updatedHistory, redoHistory: []),
    );

    _autoSaveDrawing(texts: texts);
  }

  /// -------------------------
  /// Undo
  /// -------------------------
  void undo() {
    if (state.history.isEmpty) return;

    final updatedHistory = List<DrawingAction>.from(state.history);
    final lastAction = updatedHistory.removeLast();

    final updatedRedo = List<DrawingAction>.from(state.redoHistory)
      ..add(lastAction);

    // إزالة آخر عنصر بناءً على نوعه
    switch (lastAction.type) {
      case "path":
        final updatedPaths = List<PathData>.from(state.currentPaths)
          ..remove(lastAction.data);
        emit(
          state.copyWith(
            currentPaths: updatedPaths,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: updatedPaths,
          shapes: state.shapes,
          texts: state.textData,
        );
        break;
      case "shape":
        final updatedShapes = List<ShapeData>.from(state.shapes)
          ..remove(lastAction.data);
        emit(
          state.copyWith(
            shapes: updatedShapes,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: updatedShapes,
          texts: state.textData,
        );
        break;
      case "text":
        final updatedTexts = List<TextData>.from(state.textData)
          ..remove(lastAction.data);
        emit(
          state.copyWith(
            textData: updatedTexts,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: state.shapes,
          texts: updatedTexts,
        );
        break;
    }
  }

  /// -------------------------
  /// Redo
  /// -------------------------
  void redo() {
    if (state.redoHistory.isEmpty) return;

    final updatedRedo = List<DrawingAction>.from(state.redoHistory);
    final action = updatedRedo.removeLast();

    final updatedHistory = List<DrawingAction>.from(state.history)..add(action);

    switch (action.type) {
      case "path":
        final updatedPaths = List<PathData>.from(state.currentPaths)
          ..add(action.data);
        emit(
          state.copyWith(
            currentPaths: updatedPaths,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: updatedPaths,
          shapes: state.shapes,
          texts: state.textData,
        );
        break;
      case "shape":
        final updatedShapes = List<ShapeData>.from(state.shapes)
          ..add(action.data);
        emit(
          state.copyWith(
            shapes: updatedShapes,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: updatedShapes,
          texts: state.textData,
        );
        break;
      case "text":
        final updatedTexts = List<TextData>.from(state.textData)
          ..add(action.data);
        emit(
          state.copyWith(
            textData: updatedTexts,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: state.shapes,
          texts: updatedTexts,
        );
        break;
    }
  }

  /// -------------------------
  /// مسح كل الرسومات الحالية
  /// -------------------------
  void clearCanvas() {
    emit(
      state.copyWith(
        currentPaths: [],
        shapes: [],
        textData: [],
        history: [],
        redoHistory: [],
      ),
    );
    _autoSaveDrawing(paths: [], shapes: [], texts: []);
  }

  void eraseAtPosition(Offset pos) {
    if (state.tool != "eraser") return;

    // مسح أي PathData تحتوي على نقطة pos تقريباً
    final updatedPaths = state.currentPaths.where((path) {
      return !path.points.any((p) => (p - pos).distance < state.strokeWidth);
    }).toList();

    // مسح أي شكل يحتوي على نقطة pos (حسب نوعه)
    final updatedShapes = state.shapes.where((shape) {
      if (shape.type == "rect") {
        // نتحقق من null قبل الوصول
        if (shape.start == null || shape.end == null) return true;

        return !(pos.dx >= shape.start!.dx &&
            pos.dx <= shape.end!.dx &&
            pos.dy >= shape.start!.dy &&
            pos.dy <= shape.end!.dy);
      } else if (shape.type == "circle") {
        if (shape.center == null || shape.radius == null) return true;

        return (pos - shape.center!).distance > shape.radius!;
      }
      return true;
    }).toList();

    // مسح أي نص يحتوي على نقطة pos
    final updatedTexts = state.textData.where((text) {
      return (pos - text.position).distance > text.fontSize;
    }).toList();

    emit(
      state.copyWith(
        currentPaths: updatedPaths,
        shapes: updatedShapes,
        textData: updatedTexts,
      ),
    );

    _autoSaveDrawing(
      paths: updatedPaths,
      shapes: updatedShapes,
      texts: updatedTexts,
    );
  }

  // /// -------------------------
  // /// حفظ الرسم النهائي في Drawings
  // /// -------------------------
  // void saveDrawing(DrawingModel drawing) {
  //   final updatedDrawings = state.drawings.clone()..add(drawing);
  //   emit(state.copyWith(drawings: updatedDrawings));
  // }

  /// -------------------------
  /// تمكين أو تعطيل الخط المستقيم
  /// -------------------------
  void toggleStraightLine(bool enabled) {
    emit(state.copyWith(straightLineEnabled: enabled));
    _autoSaveDrawing();
  }

  // تفعيل/إلغاء أداة اليد (Hand Tool)
  void toggleHandTool(bool enabled) {
    emit(
      state.copyWith(isHandTool: enabled, tool: enabled ? "hand" : state.tool),
    );
    _autoSaveDrawing();
  }

  /// -------------------------
  /// إضافة نص مع اللون والحجم المحدد
  /// -------------------------
  void addTextWithStyle({
    required String text,
    required Offset position,
    Color? color,
    double? fontSize,
  }) {
    addText(
      text,
      color: color,
      fontSize: fontSize ?? state.strokeWidth * 4,
      position: position,
    ); // تستخدم الدالة الأساسية لإضافة النص + history
  }

  /// -------------------------
  /// تعديل نص محدد
  /// -------------------------

  void updateText({
    required String newText,
    Color? newColor,
    double? newFontSize,
  }) {
    if (selectedTextIndex == null) return;

    final texts = List<TextData>.from(state.textData);
    final oldText = texts[selectedTextIndex!];

    final updatedText = TextData(
      id: oldText.id,
      text: newText,
      color: newColor ?? oldText.color,
      fontSize: newFontSize ?? oldText.fontSize,
      position: oldText.position,
    );

    texts[selectedTextIndex!] = updatedText;

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(
        DrawingAction(
          type: "update_text",
          data: updatedText,
          previousData: oldText,
        ),
      );

    emit(
      state.copyWith(textData: texts, history: updatedHistory, redoHistory: []),
    );

    _autoSaveDrawing(texts: texts);
  }

  /// -------------------------
  /// حذف نص محدد
  /// -------------------------
  void deleteText(int index) {
    if (index < 0 || index >= state.textData.length) return;

    final deletedText = state.textData[index];
    final updatedTexts = state.textData.clone()..removeAt(index);

    final updatedHistory = state.history.clone()
      ..add(DrawingAction(type: "text", data: deletedText));

    emit(
      state.copyWith(
        textData: updatedTexts,
        history: updatedHistory,
        redoHistory: [],
      ),
    );
  }

  /// -------------------------
  /// تحميل الرسومات من التخزين
  /// -------------------------
  // Future<void> loadDrawings() async {
  //   final drawings = await repository?.getAllDrawings();
  //   emit(state.copyWith(drawings: drawings));
  // }

  /// -------------------------
  /// حفظ رسم جديد أو تحديثه
  /// -------------------------
  // Future<void> saveDrawing(DrawingModel drawing) async {
  //   await repository?.saveDrawing(drawing);

  //   // تحديث الحالة بعد الحفظ
  //   final updatedDrawings = List<DrawingModel>.from(state.drawings)
  //     ..removeWhere((d) => d.id == drawing.id) // إزالة القديم إذا موجود
  //     ..add(drawing);
  //   emit(state.copyWith(drawings: updatedDrawings));
  // }

  /// -------------------------
  /// حذف رسم
  /// -------------------------
  // Future<void> deleteDrawing(String id) async {
  //   await repository?.deleteDrawingById(id);

  //   final updatedDrawings = state.drawings.where((d) => d.id != id).toList();
  //   emit(state.copyWith(drawings: updatedDrawings));
  // }

  void _autoSaveDrawing({
    List<PathData>? paths,
    List<ShapeData>? shapes,
    List<TextData>? texts,
    Color? selectedColor,
    double? strokeWidth,
    String? tool,
  }) {
    if (state.drawings.isEmpty) return;

    final currentDrawing = state.drawings.last;

    final updatedDrawing = currentDrawing.copyWith(
      paths: paths ?? state.currentPaths,
      shapes: shapes ?? state.shapes,
      texts: texts ?? state.textData,
      selectedColor: selectedColor ?? state.selectedColor,
      strokeWidth: strokeWidth ?? state.strokeWidth,
      tool: tool ?? state.tool,
    );

    // repository?.saveDrawing(updatedDrawing);

    final updatedDrawings = List<DrawingModel>.from(state.drawings)
      ..removeWhere((d) => d.id == updatedDrawing.id)
      ..add(updatedDrawing);

    emit(
      state.copyWith(
        drawings: updatedDrawings,
        selectedColor: selectedColor ?? state.selectedColor,
        strokeWidth: strokeWidth ?? state.strokeWidth,
        tool: tool ?? state.tool,
        textData: texts ?? state.textData,
      ),
    );
  }

  /// ID أو Index للنص المحدد
  int? selectedTextIndex;

  /// -------------------------
  /// اختيار نص موجود
  /// -------------------------
  void selectText(int index) {
    if (index >= 0 && index < state.textData.length) {
      selectedTextIndex = index;
    } else {
      selectedTextIndex = null;
    }
    emit(state.copyWith());
  }

  /// -------------------------
  /// حذف نص محدد
  /// -------------------------
  void deleteSelectedText() {
    if (selectedTextIndex == null) return;

    final texts = List<TextData>.from(state.textData);
    final removedText = texts.removeAt(selectedTextIndex!);

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(DrawingAction(type: "delete_text", data: removedText));

    selectedTextIndex = null;

    emit(
      state.copyWith(textData: texts, history: updatedHistory, redoHistory: []),
    );

    _autoSaveDrawing(texts: texts);
  }

  /// -------------------------
  /// تحريك نص محدد
  /// -------------------------
  void moveSelectedText(Offset newPosition) {
    if (selectedTextIndex == null) return;

    final texts = List<TextData>.from(state.textData);
    final oldText = texts[selectedTextIndex!];

    final updatedText = TextData(
      id: oldText.id,
      text: oldText.text,
      color: oldText.color,
      fontSize: oldText.fontSize,
      position: newPosition,
    );

    texts[selectedTextIndex!] = updatedText;

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(
        DrawingAction(
          type: "move_text",
          data: updatedText,
          previousData: oldText,
        ),
      );

    emit(
      state.copyWith(textData: texts, history: updatedHistory, redoHistory: []),
    );

    _autoSaveDrawing(texts: texts);
  }

  /// -------------------------
  /// تعديل حجم النص المحدد
  /// -------------------------
  void updateSelectedTextFontSize(double newFontSize) {
    if (selectedTextIndex == null) return;

    final texts = List<TextData>.from(state.textData);
    final oldText = texts[selectedTextIndex!];

    final updatedText = TextData(
      id: oldText.id,
      text: oldText.text,
      color: oldText.color,
      fontSize: newFontSize,
      position: oldText.position,
    );

    texts[selectedTextIndex!] = updatedText;

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(
        DrawingAction(
          type: "resize_text",
          data: updatedText,
          previousData: oldText,
        ),
      );

    emit(
      state.copyWith(textData: texts, history: updatedHistory, redoHistory: []),
    );

    _autoSaveDrawing(texts: texts);
  }

  /// -------------------------
  /// تعديل لون النص المحدد
  /// -------------------------
  void updateSelectedTextColor(Color newColor) {
    if (selectedTextIndex == null) return;

    final texts = List<TextData>.from(state.textData);
    final oldText = texts[selectedTextIndex!];

    final updatedText = TextData(
      id: oldText.id,
      text: oldText.text,
      color: newColor,
      fontSize: oldText.fontSize,
      position: oldText.position,
    );

    texts[selectedTextIndex!] = updatedText;

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(
        DrawingAction(
          type: "recolor_text",
          data: updatedText,
          previousData: oldText,
        ),
      );

    emit(
      state.copyWith(textData: texts, history: updatedHistory, redoHistory: []),
    );

    _autoSaveDrawing(texts: texts);
  }

  /// -------------------------
  /// مسح كل شيء (رسومات + نصوص)
  /// -------------------------
  void clearAll() {
    if (state.currentPaths.isEmpty && state.textData.isEmpty) return;

    final clearedState = DrawingAction(
      type: "clear_all",
      data: {
        "paths": List<PathData>.from(state.currentPaths),
        "texts": List<TextData>.from(state.textData),
      },
    );

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(clearedState);

    emit(
      state.copyWith(
        currentPaths: [],
        textData: [],
        history: updatedHistory,
        redoHistory: [],
        selectedTextIndex: null,
      ),
    );

    _autoSaveDrawing(paths: [], texts: []);
  }

  // DrawingModel getCurrentDrawing({required String projectId}) {
  //   return DrawingModel(
  //     id: DateTime.now().millisecondsSinceEpoch.toString(),
  //     projectId: projectId,
  //     title: "رسمة جديدة",
  //     paths: state.currentPaths,
  //     shapes: state.shapes,
  //     texts: state.textData,
  //   );
  // }
}
