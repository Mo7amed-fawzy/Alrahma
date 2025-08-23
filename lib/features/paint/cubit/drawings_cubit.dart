import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/core/utils/cache_keys.dart';
import '../../../../core/database/cache/app_preferences.dart';
import '../../../../core/models/drawing_model.dart';
import '../../../../core/models/project_model.dart';

class DrawingsState {
  final List<DrawingModel> drawings;
  final List<ProjectModel> projects;

  DrawingsState({required this.drawings, required this.projects});

  DrawingsState copyWith({
    List<DrawingModel>? drawings,
    List<ProjectModel>? projects,
  }) {
    return DrawingsState(
      drawings: drawings ?? this.drawings,
      projects: projects ?? this.projects,
    );
  }
}

class DrawingsCubit extends Cubit<DrawingsState> {
  final AppPreferences drawingsPrefs;
  final AppPreferences projectsPrefs;

  // 🔹 حالة الممحاة
  bool isErasing = false;

  DrawingsCubit({required this.drawingsPrefs, required this.projectsPrefs})
    : super(DrawingsState(drawings: [], projects: []));

  Future<void> load() async {
    final drawings = await drawingsPrefs.getModels(
      CacheKeys.drawingsKey,
      (j) => DrawingModel.fromJson(j),
    );
    final projects = await projectsPrefs.getModels(
      CacheKeys.projectsKey,
      (j) => ProjectModel.fromJson(j),
    );
    emit(DrawingsState(drawings: drawings, projects: projects));
  }

  Future<void> addDrawing(DrawingModel d) async {
    final updated = List<DrawingModel>.from(state.drawings)..add(d);
    await drawingsPrefs.saveModels(
      CacheKeys.drawingsKey,
      updated,
      (d) => d.toJson(),
    );
    emit(state.copyWith(drawings: updated));
  }

  Future<void> deleteDrawing(int i) async {
    final updated = List<DrawingModel>.from(state.drawings)..removeAt(i);
    await drawingsPrefs.saveModels(
      CacheKeys.drawingsKey,
      updated,
      (d) => d.toJson(),
    );
    emit(state.copyWith(drawings: updated));
  }

  // 🔹 تبديل حالة الممحاة
  void toggleEraser() {
    isErasing = !isErasing;
    emit(state.copyWith()); // لإعادة بناء واجهة المستخدم
  }
}
