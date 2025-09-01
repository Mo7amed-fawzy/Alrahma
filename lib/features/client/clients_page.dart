import 'package:alrahma/core/services/trial_guard.dart';
import 'package:alrahma/core/widgets/show_confirm_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/utils/cache_keys.dart';
import 'package:alrahma/features/client/card.dart';
import 'package:alrahma/features/client/cubit/clients_cubit.dart';
import 'package:alrahma/features/home/widgets/build_premium_loader.dart';
import '../../core/database/cache/app_preferences.dart';
import '../../core/models/client_model.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/custom_text_styles.dart';

/// BlocProvider هنا موجود قبل ما نعرض الصفحة
class ClientsPage extends StatelessWidget {
  final AppPreferences clientsPrefs;

  const ClientsPage({super.key, required this.clientsPrefs});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ClientsCubit(clientsPrefs: clientsPrefs),
      child: const ClientsPageContent(),
    );
  }
}

/// الصفحة اللي هتبني الـ UI
class ClientsPageContent extends StatelessWidget {
  const ClientsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final trialChecker = TrialChecker();

    // ✅ Check trial on page build
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await trialChecker.checkTrial(context);
    });

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'العملاء',
            style: CustomTextStyles.cairoBold20.copyWith(fontSize: 22.sp),
          ),
          backgroundColor: AppColors.primaryBlue,
          centerTitle: true,
        ),
        body: BlocBuilder<ClientsCubit, ClientsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(child: buildPremiumLoader());
            }

            if (state.clients.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 80.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا يوجد عملاء بعد',
                      style: CustomTextStyles.cairoRegular18.copyWith(
                        fontSize: 18.sp,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              itemCount: state.clients.length,
              itemBuilder: (context, index) {
                final client = state.clients[index];
                return GestureDetector(
                  onTap: () async {
                    // ✅ Optional: check trial before allowing interaction
                    final allowed = await trialChecker.checkTrial(context);
                    if (!allowed) return;

                    await context.read<ClientsCubit>().clientsPrefs.setData(
                      CacheKeys.clientId,
                      client.id,
                    );
                  },
                  child: buildClientCard(
                    client: client,
                    onEdit: () => showClientDialog(
                      context: context,
                      initial: client,
                      isNew: false,
                      onSave: (updated) =>
                          context.read<ClientsCubit>().editClient(updated),
                    ),
                    onDelete: () async {
                      final confirmed = await showConfirmDeleteDialog(
                        context,
                        itemName: client.name,
                      );

                      if (confirmed == true) {
                        context.read<ClientsCubit>().deleteClient(client.id);
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            // ✅ Check trial before allowing to add new client
            final allowed = await trialChecker.checkTrial(context);
            if (!allowed) return;

            final id = DateTime.now().millisecondsSinceEpoch.toString();
            showClientDialog(
              context: context,
              initial: ClientModel(id: id, name: '', phone: '', address: ''),
              isNew: true,
              onSave: (updated) =>
                  context.read<ClientsCubit>().addClient(updated),
            );
          },
          backgroundColor: AppColors.primaryBlue,
          child: Icon(Icons.add, size: 28.sp),
        ),
      ),
    );
  }
}
