import 'package:alrahma/features/client/cubit/clients_cubit.dart';
import 'package:alrahma/features/project/cubit/projects_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/funcs/init_and_load_databases.dart';
import 'package:alrahma/features/payment/cubit/payments_cubit.dart';
import 'package:flutter/widgets.dart';

class HomeState {
  final bool isLoading;
  HomeState({required this.isLoading});

  HomeState copyWith({bool? isLoading}) {
    return HomeState(isLoading: isLoading ?? this.isLoading);
  }
}

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState(isLoading: true));

  /// تحميل قواعد البيانات الأساسية (موجودة عندك)
  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true));
    await Future.delayed(const Duration(milliseconds: 500)); // محاكاة تحميل
    await loadDatabases(); // تحميل فعلي
    emit(state.copyWith(isLoading: false));
  }

  /// تحميل كل الداتا الخاصة بالـ Cubits التانية
  Future<void> refreshAll(BuildContext context) async {
    emit(state.copyWith(isLoading: true));

    // هنا نستدعي باقي الـ Cubits
    await context.read<PaymentsCubit>().loadPayments();
    await context.read<ProjectsCubit>().loadProjects();
    await context.read<ClientsCubit>().loadAllData();

    emit(state.copyWith(isLoading: false));
  }
}
