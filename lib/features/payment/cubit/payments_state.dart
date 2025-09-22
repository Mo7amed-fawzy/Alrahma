part of 'payments_cubit.dart';

class PaymentsState {
  final bool isLoading;
  final List<PaymentModel> payments;
  final List<ProjectModel> projects;
  final List<ClientModel> clients;
  final List<PaymentModel> filteredPayments;
  final List<DateTime> availableDates;

  PaymentsState({
    required this.isLoading,
    required this.payments,
    required this.projects,
    required this.clients,
    List<PaymentModel>? filteredPayments,
    List<DateTime>? availableDates,
  }) : filteredPayments = filteredPayments ?? payments,
       availableDates = availableDates ?? const [];

  factory PaymentsState.initial() {
    return PaymentsState(
      isLoading: false,
      payments: const [],
      projects: const [],
      clients: const [],
      filteredPayments: const [],
      availableDates: const [],
    );
  }

  PaymentsState copyWith({
    bool? isLoading,
    List<PaymentModel>? payments,
    List<ProjectModel>? projects,
    List<ClientModel>? clients,
    List<PaymentModel>? filteredPayments,
    List<DateTime>? availableDates,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      projects: projects ?? this.projects,
      clients: clients ?? this.clients,
      filteredPayments: filteredPayments ?? this.filteredPayments,
      availableDates: availableDates ?? this.availableDates,
    );
  }
}
