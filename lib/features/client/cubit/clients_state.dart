import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/models/drawing_model.dart';

class ClientsState {
  final List<ClientModel> clients;
  final List<ClientModel> filteredClients;
  final List<ProjectModel> projects;
  final List<DrawingModel> drawings;
  final bool isLoading;

  const ClientsState({
    required this.clients,
    required this.filteredClients,
    required this.projects,
    required this.drawings,
    required this.isLoading,
  });

  factory ClientsState.initial() => const ClientsState(
    clients: [],
    filteredClients: [],
    projects: [],
    drawings: [],
    isLoading: false,
  );

  ClientsState copyWith({
    List<ClientModel>? clients,
    List<ClientModel>? filteredClients,
    List<ProjectModel>? projects,
    List<DrawingModel>? drawings,
    bool? isLoading,
  }) {
    return ClientsState(
      clients: clients ?? this.clients,
      filteredClients: filteredClients ?? this.filteredClients,
      projects: projects ?? this.projects,
      drawings: drawings ?? this.drawings,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
