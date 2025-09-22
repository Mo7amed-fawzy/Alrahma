import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/cache/app_preferences.dart';
import '../../../core/models/project_model.dart';
import '../../../core/models/client_model.dart';

part 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final AppPreferences projectsPrefs;
  final AppPreferences clientsPrefs;

  static const String _projectsKey = 'projects_list';
  static const String _clientsKey = 'clients_list';

  ProjectsCubit({required this.projectsPrefs, required this.clientsPrefs})
    : super(ProjectsState.initial()) {
    loadProjects();
  }

  Future<void> loadProjects() async {
    emit(state.copyWith(isLoading: true));

    final projects = await projectsPrefs.getModels(
      _projectsKey,
      (j) => ProjectModel.fromJson(j),
    );

    final clients = await clientsPrefs.getModels(
      _clientsKey,
      (j) => ClientModel.fromJson(j),
    );

    // ربط كل مشروع باسم العميل
    final projectsWithClientName = projects.map((project) {
      final client = clients.firstWhere(
        (c) => c.id == project.clientId,
        orElse: () =>
            ClientModel(id: '', name: 'غير معروف', phone: '', address: ''),
      );
      project.clientName = client.name; // ✅ اضفنا clientName
      return project;
    }).toList();

    emit(
      state.copyWith(
        isLoading: false,
        projects: projectsWithClientName,
        clients: clients,
      ),
    );
  }

  Future<void> saveAllProjects() async {
    await projectsPrefs.saveModels(
      _projectsKey,
      state.projects,
      (p) => p.toJson(),
    );
  }

  void addProject(ProjectModel p) async {
    final updatedList = List<ProjectModel>.from(state.projects)..add(p);
    emit(state.copyWith(projects: updatedList));
    await saveAllProjects();
  }

  void editProject(ProjectModel p) async {
    final updatedList = state.projects
        .map((e) => e.id == p.id ? p : e)
        .toList();
    emit(state.copyWith(projects: updatedList));
    await saveAllProjects();
  }

  void deleteProject(String id) async {
    final updatedList = state.projects.where((e) => e.id != id).toList();
    emit(state.copyWith(projects: updatedList));
    await saveAllProjects();
  }
}
