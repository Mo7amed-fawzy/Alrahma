import 'package:alrahma/features/client/repo/clients_repository.dart';
import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:alrahma/features/project/cubit/projects_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/features/client/cubit/clients_state.dart';

class ClientsCubit extends Cubit<ClientsState> {
  final ClientsRepository repository;
  final ProjectsCubit projectsCubit;
  final PaymentsCubit paymentsCubit;

  ClientsCubit({
    required this.repository,
    required this.projectsCubit,
    required this.paymentsCubit,
  }) : super(ClientsState.initial()) {
    loadAllData();
  }

  Future<void> loadAllData() async {
    emit(state.copyWith(isLoading: true));

    final clients = await repository.getClients();
    final projects = await repository.getProjects();
    final drawings = await repository.getDrawings();

    emit(
      state.copyWith(
        isLoading: false,
        clients: clients,
        filteredClients: clients,
        projects: projects,
        drawings: drawings,
      ),
    );
  }

  Future<void> addClient(ClientModel client) async {
    final updated = List<ClientModel>.from(state.clients)..add(client);
    await repository.saveClients(updated);
    await loadAllData();
  }

  Future<void> editClient(ClientModel client) async {
    final updated = state.clients
        .map((e) => e.id == client.id ? client : e)
        .toList();
    await repository.saveClients(updated);
    await loadAllData();
  }

  Future<void> deleteClient(String id, BuildContext context) async {
    // 1️⃣ حذف العميل نفسه
    final updatedClients = state.clients.where((c) => c.id != id).toList();
    await repository.saveClients(updatedClients);

    // 2️⃣ حذف كل المشاريع المرتبطة بالعميل
    final updatedProjects = projectsCubit.state.projects
        .where((p) => p.clientId != id)
        .toList();
    projectsCubit.emit(projectsCubit.state.copyWith(projects: updatedProjects));
    await projectsCubit.saveAllProjects();

    // 3️⃣ حذف كل الدفعات المرتبطة بالمشاريع المحذوفة
    final updatedPayments = paymentsCubit.state.payments
        .where((p) => updatedProjects.any((proj) => proj.id == p.projectId))
        .toList();
    paymentsCubit.emit(
      paymentsCubit.state.copyWith(
        payments: updatedPayments,
        filteredPayments: updatedPayments,
      ),
    );
    await paymentsCubit.saveAllPayments();
    await paymentsCubit.saveDates();

    // 4️⃣ إعادة تحميل البيانات في ClientsCubit
    await loadAllData();
  }

  // // داخل ClientsCubit
  // Future<void> saveSelectedClientId(String id) async {
  //   await repository.saveSelectedClientId(id);
  // }

  void filterClients(String query) {
    if (query.isEmpty) {
      emit(state.copyWith(filteredClients: state.clients));
    } else {
      final lower = query.toLowerCase();
      final filtered = state.clients.where((c) {
        return c.name.toLowerCase().contains(lower) ||
            c.phone.toLowerCase().contains(lower) ||
            c.address.toLowerCase().contains(lower);
      }).toList();
      emit(state.copyWith(filteredClients: filtered));
    }
  }

  int getProjectsCount(BuildContext context, String clientId) {
    return context
        .read<ProjectsCubit>()
        .state
        .projects
        .where((p) => p.clientId == clientId)
        .length;
  }

  int getDrawingsCount(BuildContext context, String clientId) {
    final projects = context.watch<ProjectsCubit>().state.projects;
    final drawings = context.watch<DrawingsCubit>().state.drawings;

    final clientProjects = projects
        .where((p) => p.clientId == clientId)
        .map((p) => p.id)
        .toSet();

    return drawings.where((d) => clientProjects.contains(d.projectId)).length;
  }
}
