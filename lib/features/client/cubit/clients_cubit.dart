import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/core/database/cache/app_preferences.dart';
import 'package:tabea/core/models/client_model.dart';
import 'package:tabea/core/utils/cache_keys.dart';

part 'clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  final AppPreferences clientsPrefs;

  ClientsCubit({required this.clientsPrefs}) : super(ClientsState.initial()) {
    loadClients();
  }

  Future<void> loadClients() async {
    emit(state.copyWith(isLoading: true));
    final clients = await clientsPrefs.getModels(
      CacheKeys.clientsStorageKey,
      (json) => ClientModel.fromJson(json),
    );
    emit(state.copyWith(isLoading: false, clients: clients));
  }

  Future<void> addClient(ClientModel client) async {
    final updated = List<ClientModel>.from(state.clients)..add(client);
    await clientsPrefs.saveModels(
      CacheKeys.clientsStorageKey,
      updated,
      (c) => c.toJson(),
    );
    emit(state.copyWith(clients: updated));
  }

  Future<void> editClient(ClientModel client) async {
    final updated = state.clients
        .map((e) => e.id == client.id ? client : e)
        .toList();
    await clientsPrefs.saveModels(
      CacheKeys.clientsStorageKey,
      updated,
      (c) => c.toJson(),
    );
    emit(state.copyWith(clients: updated));
  }

  Future<void> deleteClient(String id) async {
    final updated = state.clients.where((e) => e.id != id).toList();
    await clientsPrefs.saveModels(
      CacheKeys.clientsStorageKey,
      updated,
      (c) => c.toJson(),
    );
    emit(state.copyWith(clients: updated));
  }
}
