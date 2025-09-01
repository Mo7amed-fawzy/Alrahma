// payments/cubit/payments_state.dart
part of 'payments_cubit.dart';

class PaymentsState {
  final bool isLoading;
  final List<PaymentModel> payments;
  final List<ProjectModel> projects;
  final List<ClientModel> clients;

  PaymentsState({
    required this.isLoading,
    required this.payments,
    required this.projects,
    required this.clients,
  });

  factory PaymentsState.initial() {
    return PaymentsState(
      isLoading: false,
      payments: [],
      projects: [],
      clients: [],
    );
  }

  PaymentsState copyWith({
    bool? isLoading,
    List<PaymentModel>? payments,
    List<ProjectModel>? projects,
    List<ClientModel>? clients,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      projects: projects ?? this.projects,
      clients: clients ?? this.clients,
    );
  }
}
