import 'dart:io';
import 'package:alrahma/core/models/data/image_data.dart';
import 'package:alrahma/core/models/data/text_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_state.dart';
import 'package:alrahma/features/paint/repository/drawing_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart'; // << مهم

// بعمل فنكشن علشان اقدر اعدل علي الكلاسات المعايه منغير ما اعدل علي الاصلي
extension ListCopy<T> on List<T> {
  List<T> clone() => List<T>.from(this);
}

class DrawingCanvasCubit extends Cubit<DrawingCanvasState> {
  final DrawingRepository? repository;

  DrawingCanvasCubit({
    required List<ProjectModel> projects,
    DrawingModel? existingDrawing,
    this.repository,
  }) : super(
         DrawingCanvasState(
           projects: projects,
           selectedProjectId: existingDrawing?.projectId ?? "",
           tool: existingDrawing?.tool ?? "freehand",
           straightLineEnabled: false,
           isHandTool: existingDrawing?.tool == "hand",
           currentPaths: existingDrawing?.paths ?? [],
           shapes: existingDrawing?.shapes ?? [],
           textData: existingDrawing?.texts ?? [],
           selectedColor: existingDrawing?.selectedColor ?? Colors.black,
           strokeWidth: existingDrawing?.strokeWidth ?? 2.0,
           drawings: existingDrawing != null ? [existingDrawing] : [],
         ),
       );

  // ---------------- image actions ----------------
  Future<void> addImage({
    bool fromCamera = false,
    Offset? position,
    double width = 200,
    double height = 200,
  }) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${p.basename(pickedFile.path)}';
    final savedPath = '${appDir.path}/$fileName';
    final savedFile = await File(pickedFile.path).copy(savedPath);

    final newImage = ImageData(
      id: ImageData.generateId(),
      imagePath: savedFile.path,
      position: position ?? const Offset(100, 100),
      width: width,
      height: height,
    );

    // prepare history action
    final imageAddAction = DrawingAction(type: "image_add", data: newImage);

    final last = state.drawings.isNotEmpty ? state.drawings.last : null;

    // preserve existing history and append action
    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(imageAddAction);

    if (last == null) {
      final drawing = DrawingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        projectId: state.selectedProjectId.isNotEmpty
            ? state.selectedProjectId
            : "default",
        title: "رسمة جديدة",
        images: [newImage],
        paths: state.currentPaths,
        shapes: state.shapes,
        texts: state.textData,
        selectedColor: state.selectedColor,
        strokeWidth: state.strokeWidth,
        tool: state.tool,
      );
      if (repository != null) await repository!.add(drawing);
      emit(
        state.copyWith(
          drawings: [drawing],
          images: [newImage],
          history: updatedHistory,
          redoHistory: [],
        ),
      );
    } else {
      final updatedImages = List<ImageData>.from(last.images)..add(newImage);
      final updatedDrawing = last.copyWith(images: updatedImages);
      if (repository != null) await repository!.update(updatedDrawing);
      final updatedDrawings = List<DrawingModel>.from(state.drawings)
        ..removeWhere((d) => d.id == updatedDrawing.id)
        ..add(updatedDrawing);
      emit(
        state.copyWith(
          drawings: updatedDrawings,
          images: updatedDrawing.images,
          history: updatedHistory,
          redoHistory: [],
        ),
      );
    }

    _autoSaveDrawing(
      paths: state.currentPaths,
      shapes: state.shapes,
      texts: state.textData,
      images: state.images.isNotEmpty ? state.images : null,
    );
  }

  Future<void> loadImagesForDrawing(DrawingModel drawing) async {
    // للتأكد أن كل الصور موجودة ومسارها صحيح
    final validImages = <ImageData>[];
    for (final img in drawing.images) {
      final file = File(img.imagePath);
      if (await file.exists()) validImages.add(img);
    }

    emit(
      state.copyWith(
        drawings: state.drawings,
        images: validImages,
        textData: drawing.texts,
      ),
    );
  }

  void moveImage(String imageId, Offset newPosition) {
    final images = List<ImageData>.from(state.images);
    final index = images.indexWhere((i) => i.id == imageId);
    if (index == -1) return;

    final img = images[index];
    final prev = img;
    final updated = img.copyWith(position: newPosition);
    images[index] = updated;

    final action = DrawingAction(
      type: "image_move",
      data: updated,
      previousData: prev,
    );

    _updateLastDrawingImages(images, action: action);
  }

  void resizeImage(String imageId, double newWidth, double newHeight) {
    final images = List<ImageData>.from(state.images);
    final index = images.indexWhere((i) => i.id == imageId);
    if (index == -1) return;

    final img = images[index];
    final prev = img;
    final updated = img.copyWith(width: newWidth, height: newHeight);
    images[index] = updated;

    final action = DrawingAction(
      type: "image_resize",
      data: updated,
      previousData: prev,
    );

    _updateLastDrawingImages(images, action: action);
  }

  void _updateLastDrawingImages(
    List<ImageData> updatedImages, {
    DrawingAction? action,
  }) {
    if (state.drawings.isEmpty) {
      // still update state.images and history locally
      final updatedHistory = action != null
          ? (List<DrawingAction>.from(state.history)..add(action))
          : state.history;
      emit(
        state.copyWith(
          images: updatedImages,
          history: updatedHistory,
          redoHistory: action != null ? [] : state.redoHistory,
        ),
      );
      return;
    }

    final last = state.drawings.last.copyWith(images: updatedImages);
    final updatedDrawings = List<DrawingModel>.from(state.drawings)
      ..removeWhere((d) => d.id == last.id)
      ..add(last);

    final updatedHistory = action != null
        ? (List<DrawingAction>.from(state.history)..add(action))
        : state.history;

    emit(
      state.copyWith(
        drawings: updatedDrawings,
        images: updatedImages,
        history: updatedHistory,
        redoHistory: action != null ? [] : state.redoHistory,
      ),
    );
    repository?.update(last);
    _autoSaveDrawing(
      paths: state.currentPaths,
      shapes: state.shapes,
      texts: state.textData,
      images: updatedImages,
    );
  }

  void moveText(String textId, Offset newPosition) {
    final texts = List<TextData>.from(state.textData);
    final index = texts.indexWhere((t) => t.id == textId);
    if (index == -1) return;

    final oldText = texts[index];
    final updatedText = oldText.copyWith(position: newPosition);
    texts[index] = updatedText;

    // ========== History logic المُصحح ==========
    final updatedHistory = List<DrawingAction>.from(state.history);

    if (updatedHistory.isNotEmpty) {
      final last = updatedHistory.last;

      // ✅ دمج الحركات فقط لو آخر action كان move_text لنفس النص
      if (last.type == "move_text" &&
          last.data is TextData &&
          (last.data as TextData).id == textId) {
        final prev = last.previousData ?? oldText;
        updatedHistory[updatedHistory.length - 1] = DrawingAction(
          type: "move_text",
          data: updatedText,
          previousData: prev,
        );
      } else {
        // ✅ إضافة حركة جديدة عادي
        updatedHistory.add(
          DrawingAction(
            type: "move_text",
            data: updatedText,
            previousData: oldText,
          ),
        );
      }
    } else {
      updatedHistory.add(
        DrawingAction(
          type: "move_text",
          data: updatedText,
          previousData: oldText,
        ),
      );
    }

    // Emit
    emit(
      state.copyWith(textData: texts, history: updatedHistory, redoHistory: []),
    );

    // Auto save
    _autoSaveDrawing(texts: texts);
  }

  void resizeText(String textId, double newFontSize) {
    final texts = List<TextData>.from(state.textData);
    final index = texts.indexWhere((t) => t.id == textId);
    if (index == -1) return;

    final txt = texts[index];
    texts[index] = txt.copyWith(fontSize: newFontSize);

    _updateLastDrawingTexts(texts);
  }

  void _updateLastDrawingTexts(List<TextData> updatedTexts) {
    // لو مفيش drawings بعد، حدّث textData فقط عشان الـ UI يتفاعل فورًا
    if (state.drawings.isEmpty) {
      emit(state.copyWith(textData: updatedTexts));
      // مش ضروري تحفظ في repo لو مفيش drawing فعلي؛ لكن لو تحب تحفظ أي تغييرات عامة:
      // _autoSaveDrawing(texts: updatedTexts);
      return;
    }

    // لو في drawing أخير، حدثه مثل ما كان عندك
    final last = state.drawings.last.copyWith(texts: updatedTexts);
    final updatedDrawings = List<DrawingModel>.from(state.drawings)
      ..removeWhere((d) => d.id == last.id)
      ..add(last);

    emit(state.copyWith(drawings: updatedDrawings, textData: updatedTexts));
    repository?.update(last);
  }

  // بقية الدوال كما هي: addPath, addShape, addText, undo, redo, _autoSaveDrawing, ...

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
    Color? backgroundColor,
    bool hasBackground = false,
  }) {
    final newText = TextData(
      id: TextData.generateId(),
      text: text,
      color: color ?? state.selectedColor,
      fontSize: fontSize ?? state.strokeWidth * 4,
      position: position ?? Offset.zero,
      backgroundColor: backgroundColor,
      hasBackground: hasBackground,
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

    List<T> toList<T>(dynamic data) {
      if (data is List<T>) return data;
      return [data as T];
    }

    switch (lastAction.type) {
      // ============================================================
      // ✅ 1) UNDO MOVE TEXT  (رجّع النص لمكانه القديم)
      // ============================================================
      case "move_text":
        final TextData newText = lastAction.data as TextData;
        final TextData oldText = lastAction.previousData as TextData;

        final texts = List<TextData>.from(state.textData);
        final index = texts.indexWhere((t) => t.id == newText.id);
        if (index != -1) {
          texts[index] = oldText;
        }

        emit(
          state.copyWith(
            textData: texts,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );

        _autoSaveDrawing(texts: texts);
        break;

      // ============================================================
      // ✅ 2) UNDO ADD TEXT (احذف النص اللي اتضاف)
      // ============================================================
      case "text":
        final removedTexts = toList<TextData>(lastAction.data);
        final removedIds = removedTexts.map((t) => t.id).toSet();

        final updatedTexts = List<TextData>.from(state.textData)
          ..removeWhere((t) => removedIds.contains(t.id));

        emit(
          state.copyWith(
            textData: updatedTexts,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );

        _autoSaveDrawing(texts: updatedTexts);
        break;

      // ============================================================
      // ✅ 3) باقي الأنواع كما هي (paths – shapes – images – erase...)
      // ============================================================
      case "path":
        final removedPaths = toList<PathData>(lastAction.data);
        final updatedPaths = List<PathData>.from(state.currentPaths)
          ..removeWhere((p) => removedPaths.contains(p));
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
          images: state.images,
        );
        break;

      case "shape":
        final removedShapes = toList<ShapeData>(lastAction.data);
        final updatedShapes = List<ShapeData>.from(state.shapes)
          ..removeWhere((s) => removedShapes.contains(s));
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
          images: state.images,
        );
        break;

      case "erase":
        final data = lastAction.data as Map<String, dynamic>;
        final prevPaths = (data["prevPaths"] as List<PathData>?) ?? [];
        final prevShapes = (data["prevShapes"] as List<ShapeData>?) ?? [];
        final prevTexts = (data["prevTexts"] as List<TextData>?) ?? [];
        final prevImages = (data["prevImages"] as List<ImageData>?) ?? [];

        emit(
          state.copyWith(
            currentPaths: prevPaths,
            shapes: prevShapes,
            textData: prevTexts,
            images: prevImages,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: prevPaths,
          shapes: prevShapes,
          texts: prevTexts,
          images: prevImages,
        );
        break;

      case "image_add":
        final addedImages = toList<ImageData>(lastAction.data);
        final imagesAfterRemove = List<ImageData>.from(state.images)
          ..removeWhere((i) => addedImages.any((ai) => ai.id == i.id));
        emit(
          state.copyWith(
            images: imagesAfterRemove,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: state.shapes,
          texts: state.textData,
          images: imagesAfterRemove,
        );
        break;

      case "image_move":
      case "image_resize":
        final ImageData newImg = lastAction.data as ImageData;
        final ImageData prevImg = lastAction.previousData as ImageData;

        final imgs = List<ImageData>.from(state.images);
        final idx = imgs.indexWhere((i) => i.id == newImg.id);
        if (idx != -1) imgs[idx] = prevImg;

        emit(
          state.copyWith(
            images: imgs,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(images: imgs);
        break;

      case "clear_all":
        final c = lastAction.data as Map<String, dynamic>? ?? {};
        emit(
          state.copyWith(
            currentPaths: c["paths"] ?? [],
            shapes: c["shapes"] ?? [],
            textData: c["texts"] ?? [],
            images: c["images"] ?? [],
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: c["paths"],
          shapes: c["shapes"],
          texts: c["texts"],
          images: c["images"],
        );
        break;

      default:
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

    List<T> toList<T>(dynamic data) {
      if (data is List<T>) return data;
      return [data as T];
    }

    switch (action.type) {
      case "path":
        final addedPaths = toList<PathData>(action.data);
        final updatedPaths = List<PathData>.from(state.currentPaths)
          ..addAll(addedPaths);
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
          images: state.images,
        );
        break;
      case "shape":
        final addedShapes = toList<ShapeData>(action.data);
        final updatedShapes = List<ShapeData>.from(state.shapes)
          ..addAll(addedShapes);
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
          images: state.images,
        );
        break;
      case "text":
        final addedTexts = toList<TextData>(action.data);
        final updatedTexts = List<TextData>.from(state.textData)
          ..addAll(addedTexts);
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
          images: state.images,
        );
        break;

      // images redo
      case "image_add":
        final addedImages = toList<ImageData>(action.data);
        final imagesAfterAdd = List<ImageData>.from(state.images)
          ..addAll(addedImages);
        emit(
          state.copyWith(
            images: imagesAfterAdd,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: state.shapes,
          texts: state.textData,
          images: imagesAfterAdd,
        );
        break;
      case "erase":
        final data = action.data as Map<String, dynamic>;
        final newPaths = (data["newPaths"] as List<PathData>?) ?? [];
        final newShapes = (data["newShapes"] as List<ShapeData>?) ?? [];
        final newTexts = (data["newTexts"] as List<TextData>?) ?? [];
        final newImages = (data["newImages"] as List<ImageData>?) ?? [];

        emit(
          state.copyWith(
            currentPaths: newPaths,
            shapes: newShapes,
            textData: newTexts,
            images: newImages,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );

        _autoSaveDrawing(
          paths: newPaths,
          shapes: newShapes,
          texts: newTexts,
          images: newImages,
        );
        break;

      case "image_remove":
        final removedImages = toList<ImageData>(action.data);
        final imagesAfterRemove = List<ImageData>.from(state.images)
          ..removeWhere((i) => removedImages.any((ri) => ri.id == i.id));
        emit(
          state.copyWith(
            images: imagesAfterRemove,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: state.shapes,
          texts: state.textData,
          images: imagesAfterRemove,
        );
        break;

      case "image_move":
      case "image_resize":
        final ImageData newImg = action.data as ImageData;
        // final ImageData prevImg = action.previousData as ImageData;
        // redo reapplies 'newImg'
        final imgs = List<ImageData>.from(state.images);
        final idx = imgs.indexWhere((i) => i.id == newImg.id);
        if (idx != -1) {
          imgs[idx] = newImg;
        } else {
          imgs.add(newImg);
        }
        emit(
          state.copyWith(
            images: imgs,
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(
          paths: state.currentPaths,
          shapes: state.shapes,
          texts: state.textData,
          images: imgs,
        );
        break;

      case "clear_all":
        // final data = action.data as Map<String, dynamic>? ?? {};
        // final prevPaths = (data["paths"] as List<PathData>?) ?? [];
        // final prevShapes = (data["shapes"] as List<ShapeData>?) ?? [];
        // final prevTexts = (data["texts"] as List<TextData>?) ?? [];
        // final prevImages = (data["images"] as List<ImageData>?) ?? [];

        // here redo means re-apply clear -> so set all to empty
        emit(
          state.copyWith(
            currentPaths: [],
            shapes: [],
            textData: [],
            images: [],
            history: updatedHistory,
            redoHistory: updatedRedo,
          ),
        );
        _autoSaveDrawing(paths: [], shapes: [], texts: [], images: []);
        break;

      default:
        break;
    }
  }

  /// -------------------------
  /// مسح كل الرسومات الحالية
  /// -------------------------
  void clearCanvas() {
    // Save previous state in history to allow undo
    final clearedState = DrawingAction(
      type: "clear_all",
      data: {
        "paths": List<PathData>.from(state.currentPaths),
        "shapes": List<ShapeData>.from(state.shapes),
        "texts": List<TextData>.from(state.textData),
        "images": List<ImageData>.from(state.images),
      },
    );

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(clearedState);

    emit(
      state.copyWith(
        currentPaths: [],
        shapes: [],
        textData: [],
        images: [],
        history: updatedHistory,
        redoHistory: [],
      ),
    );

    _autoSaveDrawing(paths: [], shapes: [], texts: [], images: []);
  }

  void eraseAtPosition(Offset pos) {
    if (state.tool != "eraser") return;

    double eraseRadius = state.strokeWidth * 1.5;

    final prevPaths = List<PathData>.from(state.currentPaths);
    final prevShapes = List<ShapeData>.from(state.shapes);
    final prevTexts = List<TextData>.from(state.textData);
    final prevImages = List<ImageData>.from(state.images);

    // حساب القوائم بعد المسح (كما عندك)
    final updatedPaths = prevPaths.where((path) {
      if (path.points.length == 2) {
        final p1 = path.points.first;
        final p2 = path.points.last;

        double distanceToLine(Offset a, Offset b, Offset p) {
          final numerator =
              ((b.dy - a.dy) * p.dx -
                      (b.dx - a.dx) * p.dy +
                      b.dx * a.dy -
                      b.dy * a.dx)
                  .abs();
          final den = (b - a).distance;
          return den == 0 ? (p - a).distance : numerator / den;
        }

        return distanceToLine(p1, p2, pos) > eraseRadius * 1.5;
      } else {
        return !path.points.any((p) => (p - pos).distance <= eraseRadius);
      }
    }).toList();

    final updatedShapes = prevShapes.where((shape) {
      if (shape.type == "rect" && shape.start != null && shape.end != null) {
        final rect = Rect.fromPoints(shape.start!, shape.end!);
        return !rect.inflate(eraseRadius).contains(pos);
      } else if (shape.type == "circle" &&
          shape.center != null &&
          shape.radius != null) {
        return (pos - shape.center!).distance > shape.radius! + eraseRadius;
      } else if (shape.path != null) {
        final pathBounds = shape.path!.getBounds().inflate(eraseRadius);
        return !pathBounds.contains(pos);
      }
      return true;
    }).toList();

    final updatedTexts = prevTexts.where((text) {
      final textRect = Rect.fromLTWH(
        text.position.dx,
        text.position.dy,
        text.fontSize * text.text.length * 0.5,
        text.fontSize,
      ).inflate(eraseRadius);
      return !textRect.contains(pos);
    }).toList();

    final removedImages = <ImageData>[];
    final keptImages = <ImageData>[];
    for (final img in prevImages) {
      final rect = Rect.fromLTWH(
        img.position.dx,
        img.position.dy,
        img.width,
        img.height,
      ).inflate(eraseRadius);
      if (rect.contains(pos)) {
        removedImages.add(img);
      } else {
        keptImages.add(img);
      }
    }

    // احسب العناصر المحذوفة فعلاً عن طريق المقارنة prev - next
    final removedPaths = prevPaths
        .where((p) => !updatedPaths.contains(p))
        .toList();
    final removedShapes = prevShapes
        .where((s) => !updatedShapes.contains(s))
        .toList();

    // ===== هنا: استخدمنا مقارنة بالـ id بدلاً من contains على الـ objects =====
    final removedTexts = prevTexts
        .where((t) => !updatedTexts.any((ut) => ut.id == t.id))
        .toList();

    // لو ما اتشال شيء، لا تضيف history
    if (removedPaths.isEmpty &&
        removedShapes.isEmpty &&
        removedTexts.isEmpty &&
        removedImages.isEmpty) {
      return;
    }

    final eraseAction = DrawingAction(
      type: "erase",
      data: {
        "prevPaths": prevPaths,
        "prevShapes": prevShapes,
        "prevTexts": prevTexts,
        "prevImages": prevImages,
        "newPaths": updatedPaths,
        "newShapes": updatedShapes,
        "newTexts": updatedTexts,
        "newImages": keptImages,
        "removedPaths": removedPaths,
        "removedShapes": removedShapes,
        "removedTexts": removedTexts,
        "removedImages": removedImages,
      },
    );

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(eraseAction);

    emit(
      state.copyWith(
        currentPaths: updatedPaths,
        shapes: updatedShapes,
        textData: updatedTexts,
        images: keptImages,
        history: updatedHistory,
        redoHistory: [], // بعد عمل جديد نمسح redo
      ),
    );

    _autoSaveDrawing(
      paths: updatedPaths,
      shapes: updatedShapes,
      texts: updatedTexts,
      images: keptImages,
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

  void updateText(
    String id,
    String newText, {
    Offset? newPosition,
    Color? newColor,
    double? newFontSize,
    bool? hasBackground,
    Color? backgroundColor,
  }) {
    final texts = List<TextData>.from(state.textData);
    final index = texts.indexWhere((t) => t.id == id);
    if (index == -1) return;

    final oldText = texts[index];

    final updatedText = TextData(
      id: oldText.id,
      text: newText,
      position: newPosition ?? oldText.position,
      color: newColor ?? oldText.color,
      fontSize: newFontSize ?? oldText.fontSize,
      hasBackground: hasBackground ?? oldText.hasBackground,
      backgroundColor: backgroundColor ?? oldText.backgroundColor,
    );

    texts[index] = updatedText;

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

    _autoSaveDrawing(
      paths: state.currentPaths,
      shapes: state.shapes,
      texts: updatedTexts,
      images: state.images,
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
    List<ImageData>? images,
    Color? selectedColor,
    double? strokeWidth,
    String? tool,
  }) {
    if (state.drawings.isEmpty || repository == null) return;

    final currentDrawing = state.drawings.last;

    final updatedDrawing = currentDrawing.copyWith(
      paths: paths ?? state.currentPaths,
      shapes: shapes ?? state.shapes,
      texts: texts ?? state.textData,
      images: images ?? state.images,
      selectedColor: selectedColor ?? state.selectedColor,
      strokeWidth: strokeWidth ?? state.strokeWidth,
      tool: tool ?? state.tool,
    );

    repository!.update(updatedDrawing); // ← يحفظ فعليًا في التخزين

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
        images: images ?? state.images,
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
    if (state.currentPaths.isEmpty &&
        state.textData.isEmpty &&
        state.images.isEmpty)
      return;

    final clearedState = DrawingAction(
      type: "clear_all",
      data: {
        "paths": List<PathData>.from(state.currentPaths),
        "shapes": List<ShapeData>.from(state.shapes),
        "texts": List<TextData>.from(state.textData),
        "images": List<ImageData>.from(state.images),
      },
    );

    final updatedHistory = List<DrawingAction>.from(state.history)
      ..add(clearedState);

    emit(
      state.copyWith(
        currentPaths: [],
        textData: [],
        images: [],
        history: updatedHistory,
        redoHistory: [],
        selectedTextIndex: null,
      ),
    );

    _autoSaveDrawing(paths: [], texts: [], images: []);
  }

  /// -------------------------
  /// إضافة صورة جديدة (كاميرا أو معرض)
  /// -------------------------
  // (تم تعريفها في بداية الملف)
}
