part of 'projects_cubit.dart';

class ProjectsState {
  final bool isLoading;
  final List<ProjectModel> projects;
  final List<ClientModel> clients;

  ProjectsState({
    required this.isLoading,
    required this.projects,
    required this.clients,
  });

  factory ProjectsState.initial() {
    return ProjectsState(isLoading: false, projects: [], clients: []);
  }

  ProjectsState copyWith({
    bool? isLoading,
    List<ProjectModel>? projects,
    List<ClientModel>? clients,
  }) {
    return ProjectsState(
      isLoading: isLoading ?? this.isLoading,
      projects: projects ?? this.projects,
      clients: clients ?? this.clients,
    );
  }
}
