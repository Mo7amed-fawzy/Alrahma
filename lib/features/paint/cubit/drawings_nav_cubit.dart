import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/database/cache/app_preferences.dart';
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
import 'package:alrahma/features/paint/repository/drawing_repository.dart';

class DrawingsState {
  final List<DrawingModel> drawings;
  final List<ProjectModel> projects;
  final List<ClientModel>? clients;
  final String selectedProjectId; // ← جديد

  DrawingsState({
    required this.drawings,
    required this.projects,
    this.clients,
    this.selectedProjectId = "", // افتراضي
  });

  DrawingsState copyWith({
    List<DrawingModel>? drawings,
    List<ProjectModel>? projects,
    List<ClientModel>? clients,
    String? selectedProjectId,
  }) {
    return DrawingsState(
      drawings: drawings ?? this.drawings,
      projects: projects ?? this.projects,
      clients: clients ?? this.clients,
      selectedProjectId: selectedProjectId ?? this.selectedProjectId,
    );
  }
}

class DrawingsCubit extends Cubit<DrawingsState> {
  final DrawingRepository repository;
  final AppPreferences clientPrefs;
  final AppPreferences drawingsPrefs;
  final AppPreferences projectsPrefs;

  DrawingsCubit({
    required this.drawingsPrefs,
    required this.projectsPrefs,
    required this.clientPrefs,
  }) : repository = DrawingRepository(drawingsPrefs: drawingsPrefs),
       super(DrawingsState(drawings: [], projects: [], clients: []));

  /// =======================
  /// Load drawings
  /// =======================
  Future<void> loadDrawings() async {
    final drawings = await repository.getAll();
    final projects = await projectsPrefs.getModels(
      CacheKeys.projectsKey,
      (j) => ProjectModel.fromJson(j),
    );
    final clients = await clientPrefs.getModels(
      CacheKeys.clientsStorageKey,
      (j) => ClientModel.fromJson(j),
    );

    emit(
      state.copyWith(drawings: drawings, projects: projects, clients: clients),
    );
  }

  /// =======================
  /// Add / Update / Delete / Clear
  /// =======================
  Future<void> addDrawing(DrawingModel d) async {
    await repository.add(d);
    await loadDrawings(); // emit updated state
  }

  Future<void> updateDrawing(DrawingModel updatedDrawing) async {
    await repository.update(updatedDrawing); // ← repository يحفظ الرسم فعليًا؟
    await loadDrawings(); // ← يعيد تحميل كل الرسومات من التخزين
  }

  Future<void> deleteDrawing(String id) async {
    await repository.delete(id);
    await loadDrawings();
  }

  Future<void> clearAll() async {
    await repository.clearAll();
    emit(state.copyWith(drawings: []));
  }

  /// =======================
  /// JSON Export / Import
  /// =======================
  String exportDrawingToJson(DrawingModel drawing) =>
      repository.exportDrawingToJson(drawing);

  Future<String> exportAllDrawingsToJson() async =>
      await repository.exportAllDrawingsToJson();

  Future<void> importDrawingsFromJson(String jsonString) async {
    await repository.importDrawingsFromJson(jsonString);
    await loadDrawings();
  }
}
