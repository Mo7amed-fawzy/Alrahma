import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/core/models/drawing_model.dart';
import 'package:tabea/core/models/project_model.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_state.dart';
import 'package:tabea/features/paint/model/models.dart';

class DrawingCanvasCubit extends Cubit<DrawingCanvasState> {
  ShapeData? currentShape;

  // رسم عادي مع دعم initialData
  DrawingCanvasCubit(List<ProjectModel> projects, {String? initialData})
    : super(
        DrawingCanvasState(
          projects: projects,
          selectedProjectId: projects.isNotEmpty ? projects.first.id : "",
        ),
      ) {
    // 🔹 لو فيه بيانات محفوظة، حوّلها للـ state
    if (initialData != null) {
      final Map<String, dynamic> jsonData = jsonDecode(initialData);

      emit(
        state.copyWith(
          paths: (jsonData['paths'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
          shapes: (jsonData['shapes'] as List<dynamic>? ?? [])
              .map((e) => ShapeData.fromMap(Map<String, dynamic>.from(e)))
              .toList(),
          texts: (jsonData['texts'] as List<dynamic>? ?? [])
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        ),
      );
    }
  }

  // preview
  DrawingCanvasCubit.preview({
    required List<Map<String, dynamic>> paths,
    required List<ShapeData> shapes,
    required List<Map<String, dynamic>> texts,
  }) : super(
         DrawingCanvasState(
           paths: paths,
           shapes: shapes,
           texts: texts,
           projects: [],
           selectedProjectId: '',
         ),
       );

  // 🟢 تغيير المشروع
  void changeProject(String projectId) {
    emit(state.copyWith(selectedProjectId: projectId));
  }

  void selectProject(String id) {
    emit(
      state.copyWith(
        selectedProjectId: id,
        paths: [],
        currentPath: [],
        history: [],
        redoHistory: [],
      ),
    );
  }

  // 🎨 إعدادات الرسم
  void changeColor(Color color) {
    emit(state.copyWith(selectedColor: color));
  }

  void changeStrokeWidth(double width) {
    emit(state.copyWith(strokeWidth: width));
  }

  void changeTool(String tool) {
    emit(state.copyWith(tool: tool));
  }

  void toggleStraightLine() {
    emit(state.copyWith(straightLineEnabled: !state.straightLineEnabled));
  }

  void updateDrawing(DrawingModel updated) {
    final index = state.drawings.indexWhere((d) => d.id == updated.id);
    if (index == -1) return;
    final newDrawings = List<DrawingModel>.from(state.drawings);
    newDrawings[index] = updated;
    emit(state.copyWith(drawings: newDrawings));
  }

  // ✏️ النصوص
  // void addText(String text, Offset position) {
  //   final newText = {
  //     'text': text,
  //     'position': position,
  //     'color': state.selectedColor,
  //     'size': state.strokeWidth * 5,
  //   };

  //   final updatedTexts = List<Map<String, dynamic>>.from(state.texts)
  //     ..add(newText);

  //   final updatedHistory = List<Map<String, dynamic>>.from(state.history)
  //     ..add({'type': 'text', 'index': updatedTexts.length - 1});

  //   emit(
  //     state.copyWith(
  //       texts: updatedTexts,
  //       history: updatedHistory,
  //       redoHistory: [],
  //     ),
  //   );
  // }

  // void updateTextContent(Map<String, dynamic> textData, String newText) {
  //   final updated = List<Map<String, dynamic>>.from(state.texts);
  //   final idx = updated.indexOf(textData);
  //   if (idx != -1) {
  //     updated[idx]['text'] = newText;
  //     emit(state.copyWith(texts: updated));
  //   }
  // }

  // void updateTextPosition(Map<String, dynamic> textData, Offset newPos) {
  //   final updated = List<Map<String, dynamic>>.from(state.texts);
  //   final idx = updated.indexOf(textData);
  //   if (idx != -1) {
  //     updated[idx]['position'] = newPos;
  //     emit(state.copyWith(texts: updated));
  //   }
  // }

  // void updateTextSize(Map<String, dynamic> textData, double newSize) {
  //   final updated = List<Map<String, dynamic>>.from(state.texts);
  //   final idx = updated.indexOf(textData);
  //   if (idx != -1) {
  //     updated[idx]['size'] = newSize;
  //     emit(state.copyWith(texts: updated));
  //   }
  // }

  // ✍️ رسم المسارات
  // void startPath(Offset startPoint) {
  //   if (state.tool == "text") return;

  //   final newPath = {
  //     'tool': state.tool,
  //     'color': state.selectedColor,
  //     'strokeWidth': state.strokeWidth,
  //     'points': <Offset>[startPoint],
  //   };

  //   final updatedPaths = List<Map<String, dynamic>>.from(state.paths)
  //     ..add(newPath);

  //   final updatedHistory = List<Map<String, dynamic>>.from(state.history)
  //     ..add({'type': 'path', 'index': updatedPaths.length - 1});

  //   emit(
  //     state.copyWith(
  //       paths: updatedPaths,
  //       currentPath: [startPoint],
  //       history: updatedHistory,
  //       redoHistory: [],
  //     ),
  //   );
  // }

  // void updatePath(Offset point) {
  //   if (state.tool == "text" || state.currentPath.isEmpty) return;

  //   final updatedCurrent = List<Offset>.from(state.currentPath)..add(point);
  //   final updatedPaths = List<Map<String, dynamic>>.from(state.paths);
  //   final last = updatedPaths.last;

  //   if (state.tool == "line" && state.straightLineEnabled) {
  //     final start = state.currentPath.first;
  //     Offset end = point;

  //     final dx = (point.dx - start.dx).abs();
  //     final dy = (point.dy - start.dy).abs();

  //     if (dx > dy * 2) {
  //       end = Offset(point.dx, start.dy);
  //     } else if (dy > dx * 2) {
  //       end = Offset(start.dx, point.dy);
  //     } else {
  //       final diff = point - start;
  //       final len = diff.distance;
  //       final signX = diff.dx >= 0 ? 1 : -1;
  //       final signY = diff.dy >= 0 ? 1 : -1;
  //       end = Offset(
  //         start.dx + signX * len / 1.4,
  //         start.dy + signY * len / 1.4,
  //       );
  //     }

  //     updatedPaths[updatedPaths.length - 1] = {
  //       ...last,
  //       'points': [start, end],
  //     };
  //   } else {
  //     updatedPaths[updatedPaths.length - 1] = {
  //       ...last,
  //       'points': updatedCurrent,
  //     };
  //   }

  //   emit(state.copyWith(paths: updatedPaths, currentPath: updatedCurrent));
  // }

  // void endPath() {
  //   emit(state.copyWith(currentPath: []));
  // }

  // 🔄 Undo/Redo
  // void undo() {
  //   if (state.history.isEmpty) return;

  //   final updatedPaths = List<Map<String, dynamic>>.from(state.paths);
  //   final updatedTexts = List<Map<String, dynamic>>.from(state.texts);
  //   final updatedHistory = List<Map<String, dynamic>>.from(state.history);
  //   final updatedRedo = List<Map<String, dynamic>>.from(state.redoHistory);

  //   final lastAction = updatedHistory.removeLast();

  //   if (lastAction['type'] == 'path') {
  //     final i = lastAction['index'] as int;
  //     if (i >= 0 && i < updatedPaths.length) {
  //       final removed = updatedPaths.removeAt(i);
  //       updatedRedo.add({'type': 'path', 'index': i, 'data': removed});
  //     }
  //   } else if (lastAction['type'] == 'text') {
  //     final i = lastAction['index'] as int;
  //     if (i >= 0 && i < updatedTexts.length) {
  //       final removed = updatedTexts.removeAt(i);
  //       updatedRedo.add({'type': 'text', 'index': i, 'data': removed});
  //     }
  //   }

  //   emit(
  //     state.copyWith(
  //       paths: updatedPaths,
  //       texts: updatedTexts,
  //       history: updatedHistory,
  //       redoHistory: updatedRedo,
  //     ),
  //   );
  // }

  // void redo() {
  //   if (state.redoHistory.isEmpty) return;

  //   final updatedPaths = List<Map<String, dynamic>>.from(state.paths);
  //   final updatedTexts = List<Map<String, dynamic>>.from(state.texts);
  //   final updatedHistory = List<Map<String, dynamic>>.from(state.history);
  //   final updatedRedo = List<Map<String, dynamic>>.from(state.redoHistory);

  //   final lastRedo = updatedRedo.removeLast();

  //   if (lastRedo['type'] == 'path') {
  //     final i = lastRedo['index'] as int;
  //     final data = Map<String, dynamic>.from(lastRedo['data'] as Map);
  //     updatedPaths.insert(i, data);
  //     updatedHistory.add({'type': 'path', 'index': i});
  //   } else if (lastRedo['type'] == 'text') {
  //     final i = lastRedo['index'] as int;
  //     final data = Map<String, dynamic>.from(lastRedo['data'] as Map);
  //     updatedTexts.insert(i, data);
  //     updatedHistory.add({'type': 'text', 'index': i});
  //   }

  //   emit(
  //     state.copyWith(
  //       paths: updatedPaths,
  //       texts: updatedTexts,
  //       history: updatedHistory,
  //       redoHistory: updatedRedo,
  //     ),
  //   );
  // }

  // void clear() {
  //   emit(state.copyWith(paths: [], texts: [], history: [], redoHistory: []));
  // }

  // 📦 Export / Import JSON
  String exportJson() {
    final data = {
      'paths': state.paths
          .map(
            (p) => {
              'color': (p['color'] as Color).value,
              'strokeWidth': p['strokeWidth'],
              'points': (p['points'] as List<Offset>)
                  .map((o) => {'x': o.dx, 'y': o.dy})
                  .toList(),
            },
          )
          .toList(),
      'texts': state.texts
          .map(
            (t) => {
              'text': t['text'],
              'x': (t['position'] as Offset).dx,
              'y': (t['position'] as Offset).dy,
              'color': (t['color'] as Color).value,
              'size': t['size'],
            },
          )
          .toList(),
    };
    return jsonEncode(data);
  }

  void loadFromDrawing(DrawingModel drawing) {
    final json = jsonDecode(drawing.drawingData) as Map<String, dynamic>;
    final decodedPaths = (json['paths'] as List).map((p) {
      return {
        'color': Color(p['color']),
        'strokeWidth': (p['strokeWidth'] as num).toDouble(),
        'points': (p['points'] as List)
            .map(
              (e) => Offset(
                (e['x'] as num).toDouble(),
                (e['y'] as num).toDouble(),
              ),
            )
            .toList(),
      };
    }).toList();

    final decodedTexts = (json['texts'] as List).map((t) {
      return {
        'text': t['text'],
        'position': Offset(
          (t['x'] as num).toDouble(),
          (t['y'] as num).toDouble(),
        ),
        'color': Color(t['color']),
        'size': (t['size'] as num).toDouble(),
      };
    }).toList();

    emit(state.copyWith(paths: decodedPaths, texts: decodedTexts));
  }

  // void changeColor(Color color) => emit(state.copyWith(selectedColor: color));
  // void changeStrokeWidth(double width) =>
  //     emit(state.copyWith(strokeWidth: width));
  // void changeTool(String tool) => emit(state.copyWith(tool: tool));
  // void toggleStraightLine() =>
  //     emit(state.copyWith(straightLineEnabled: !state.straightLineEnabled));

  // مسارات الرسم العادية
  void startPath(Offset startPoint) {
    if (state.tool == "text") return;
    final newPath = {
      'tool': state.tool,
      'color': state.selectedColor,
      'strokeWidth': state.strokeWidth,
      'points': <Offset>[startPoint],
    };
    final updatedPaths = List<Map<String, dynamic>>.from(state.paths)
      ..add(newPath);
    final updatedHistory = List<Map<String, dynamic>>.from(state.history)
      ..add({'type': 'path', 'index': updatedPaths.length - 1});
    emit(
      state.copyWith(
        paths: updatedPaths,
        currentPath: [startPoint],
        history: updatedHistory,
        redoHistory: [],
      ),
    );
  }

  void updatePath(Offset point) {
    if (state.tool == "text" || state.currentPath.isEmpty) return;

    final updatedCurrent = List<Offset>.from(state.currentPath)..add(point);
    final updatedPaths = List<Map<String, dynamic>>.from(state.paths);
    final last = updatedPaths.last;

    if (state.tool == "line" && state.straightLineEnabled) {
      final start = state.currentPath.first;
      Offset end = point;
      final dx = (point.dx - start.dx).abs();
      final dy = (point.dy - start.dy).abs();
      if (dx > dy * 2) {
        end = Offset(point.dx, start.dy);
      } else if (dy > dx * 2) {
        end = Offset(start.dx, point.dy);
      } else {
        final diff = point - start;
        final len = diff.distance;
        final signX = diff.dx >= 0 ? 1 : -1;
        final signY = diff.dy >= 0 ? 1 : -1;
        end = Offset(
          start.dx + signX * len / 1.4,
          start.dy + signY * len / 1.4,
        );
      }
      updatedPaths[updatedPaths.length - 1] = {
        ...last,
        'points': [start, end],
      };
    } else {
      updatedPaths[updatedPaths.length - 1] = {
        ...last,
        'points': updatedCurrent,
      };
    }

    emit(state.copyWith(paths: updatedPaths, currentPath: updatedCurrent));
  }

  void endPath() => emit(state.copyWith(currentPath: []));

  // ✏️ نصوص
  void addText(String text, Offset position) {
    final newText = {
      'text': text,
      'position': position,
      'color': state.selectedColor,
      'size': state.strokeWidth * 5,
    };
    final updatedTexts = List<Map<String, dynamic>>.from(state.texts)
      ..add(newText);
    final updatedHistory = List<Map<String, dynamic>>.from(state.history)
      ..add({'type': 'text', 'index': updatedTexts.length - 1});
    emit(
      state.copyWith(
        texts: updatedTexts,
        history: updatedHistory,
        redoHistory: [],
      ),
    );
  }

  void updateTextContent(Map<String, dynamic> textData, String newText) {
    final updated = List<Map<String, dynamic>>.from(state.texts);
    final idx = updated.indexOf(textData);
    if (idx != -1) {
      updated[idx]['text'] = newText;
      emit(state.copyWith(texts: updated));
    }
  }

  void updateTextPosition(Map<String, dynamic> textData, Offset newPos) {
    final updated = List<Map<String, dynamic>>.from(state.texts);
    final idx = updated.indexOf(textData);
    if (idx != -1) {
      updated[idx]['position'] = newPos;
      emit(state.copyWith(texts: updated));
    }
  }

  void updateTextSize(Map<String, dynamic> textData, double newSize) {
    final updated = List<Map<String, dynamic>>.from(state.texts);
    final idx = updated.indexOf(textData);
    if (idx != -1) {
      updated[idx]['size'] = newSize;
      emit(state.copyWith(texts: updated));
    }
  }

  // 🔄 Undo / Redo
  void undo() {
    if (state.history.isEmpty) return;
    final updatedPaths = List<Map<String, dynamic>>.from(state.paths);
    final updatedTexts = List<Map<String, dynamic>>.from(state.texts);
    final updatedHistory = List<Map<String, dynamic>>.from(state.history);
    final updatedRedo = List<Map<String, dynamic>>.from(state.redoHistory);
    final lastAction = updatedHistory.removeLast();

    if (lastAction['type'] == 'path') {
      final i = lastAction['index'] as int;
      if (i >= 0 && i < updatedPaths.length) {
        final removed = updatedPaths.removeAt(i);
        updatedRedo.add({'type': 'path', 'index': i, 'data': removed});
      }
    } else if (lastAction['type'] == 'text') {
      final i = lastAction['index'] as int;
      if (i >= 0 && i < updatedTexts.length) {
        final removed = updatedTexts.removeAt(i);
        updatedRedo.add({'type': 'text', 'index': i, 'data': removed});
      }
    }

    emit(
      state.copyWith(
        paths: updatedPaths,
        texts: updatedTexts,
        history: updatedHistory,
        redoHistory: updatedRedo,
      ),
    );
  }

  void redo() {
    if (state.redoHistory.isEmpty) return;
    final updatedPaths = List<Map<String, dynamic>>.from(state.paths);
    final updatedTexts = List<Map<String, dynamic>>.from(state.texts);
    final updatedHistory = List<Map<String, dynamic>>.from(state.history);
    final updatedRedo = List<Map<String, dynamic>>.from(state.redoHistory);
    final lastRedo = updatedRedo.removeLast();

    if (lastRedo['type'] == 'path') {
      final i = lastRedo['index'] as int;
      final data = Map<String, dynamic>.from(lastRedo['data'] as Map);
      updatedPaths.insert(i, data);
      updatedHistory.add({'type': 'path', 'index': i});
    } else if (lastRedo['type'] == 'text') {
      final i = lastRedo['index'] as int;
      final data = Map<String, dynamic>.from(lastRedo['data'] as Map);
      updatedTexts.insert(i, data);
      updatedHistory.add({'type': 'text', 'index': i});
    }

    emit(
      state.copyWith(
        paths: updatedPaths,
        texts: updatedTexts,
        history: updatedHistory,
        redoHistory: updatedRedo,
      ),
    );
  }

  void clear() =>
      emit(state.copyWith(paths: [], texts: [], history: [], redoHistory: []));

  void startShape(Offset start, String type) {
    currentShape = ShapeData(
      type: type == "rect" ? ShapeType.rectangle : ShapeType.circle,
      color: state.selectedColor,
      strokeWidth: state.strokeWidth,
      rect: type == "rect" ? Rect.fromLTWH(start.dx, start.dy, 0, 0) : null,
      center: type == "circle" ? start : null,
      radius: type == "circle" ? 0 : null,
    );
    emit(state.copyWith(shapes: [...state.shapes, currentShape!]));
  }

  void updateShape(Offset current) {
    if (currentShape == null) return;

    if (currentShape!.type == ShapeType.rectangle) {
      final rect = currentShape!.rect!;
      currentShape = currentShape!.copyWith(
        rect: Rect.fromPoints(rect.topLeft, current),
      );
    } else if (currentShape!.type == ShapeType.circle) {
      final start = currentShape!.center!;
      currentShape = currentShape!.copyWith(radius: (current - start).distance);
    }

    final updatedShapes = List<ShapeData>.from(state.shapes);
    updatedShapes.removeLast();
    updatedShapes.add(currentShape!);
    emit(state.copyWith(shapes: updatedShapes));
  }

  void endShape() {
    if (currentShape != null) {
      currentShape = null;
    }
  }
}

// 🔹 تحديث في ShapeData لإضافة copyWith
extension ShapeDataCopy on ShapeData {
  ShapeData copyWith({
    Rect? rect,
    Offset? center,
    double? radius,
    Color? color,
    double? strokeWidth,
  }) {
    return ShapeData(
      type: this.type,
      rect: rect ?? this.rect,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
    );
  }
}
