part of 'clients_cubit.dart';

class ClientsState {
  final List<ClientModel> clients;
  final bool isLoading;

  const ClientsState({required this.clients, required this.isLoading});

  factory ClientsState.initial() =>
      const ClientsState(clients: [], isLoading: false);

  ClientsState copyWith({List<ClientModel>? clients, bool? isLoading}) {
    return ClientsState(
      clients: clients ?? this.clients,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
