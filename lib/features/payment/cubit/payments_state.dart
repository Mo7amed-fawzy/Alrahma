// payments/cubit/payments_state.dart
part of 'payments_cubit.dart';

class PaymentsState {
  final bool isLoading;
  final List<PaymentModel> payments;
  final List<ProjectModel> projects;

  PaymentsState({
    required this.isLoading,
    required this.payments,
    required this.projects,
  });

  factory PaymentsState.initial() {
    return PaymentsState(isLoading: false, payments: [], projects: []);
  }

  PaymentsState copyWith({
    bool? isLoading,
    List<PaymentModel>? payments,
    List<ProjectModel>? projects,
  }) {
    return PaymentsState(
      isLoading: isLoading ?? this.isLoading,
      payments: payments ?? this.payments,
      projects: projects ?? this.projects,
    );
  }
}
