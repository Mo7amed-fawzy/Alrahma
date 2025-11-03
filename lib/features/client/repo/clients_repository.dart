// lib/features/client/data/clients_repository.dart
import 'package:alrahma/core/database/cache/app_preferences.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/models/drawing_model.dart';

class ClientsRepository {
  final AppPreferences clientsPrefs;
  final AppPreferences projectsPrefs;
  final AppPreferences drawingsPrefs;

  ClientsRepository({
    required this.clientsPrefs,
    required this.projectsPrefs,
    required this.drawingsPrefs,
  });

  Future<List<ClientModel>> getClients() async {
    return await clientsPrefs.getModels(
      CacheKeys.clientsStorageKey,
      (json) => ClientModel.fromJson(json),
    );
  }

  Future<void> saveClients(List<ClientModel> clients) async {
    await clientsPrefs.saveModels(
      CacheKeys.clientsStorageKey,
      clients,
      (c) => c.toJson(),
    );
  }

  Future<List<ProjectModel>> getProjects() async {
    return await projectsPrefs.getModels(
      CacheKeys.projectsKey,
      (json) => ProjectModel.fromJson(json),
    );
  }

  Future<List<DrawingModel>> getDrawings() async {
    return await drawingsPrefs.getModels(
      CacheKeys.drawingsKey,
      (json) => DrawingModel.fromMap(json),
    );
  }

  // في ClientsRepository
  Future<void> saveSelectedClientId(String id) async {
    await clientsPrefs.setData('clientId', id);
  }

  // Future<void> deleteClientAndAssociations(String clientId) async {
  //   final clients = await getClients();
  //   final newClients = clients.where((c) => c.id != clientId).toList();
  //   await saveClients(newClients);

  //   final projects = await getProjects();
  //   final projectsToKeep = projects
  //       .where((p) => p.clientId != clientId)
  //       .toList();
  //   await saveAllProjects(projectsToKeep);

  //   final payments = await getPayments();
  //   final paymentsToKeep = payments
  //       .where((pm) => projectsToKeep.any((pr) => pr.id == pm.projectId))
  //       .toList();
  //   await savePayments(paymentsToKeep);
  // }
}
