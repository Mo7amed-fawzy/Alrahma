import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/features/client/card.dart';
import 'package:tabea/features/client/cubit/clients_cubit.dart';
import 'package:tabea/features/home/widgets/build_premium_loader.dart';
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('العملاء', style: CustomTextStyles.cairoBold20),
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
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا يوجد عملاء بعد',
                      style: CustomTextStyles.cairoRegular18,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.clients.length,
              itemBuilder: (context, index) {
                final client = state.clients[index];
                return buildClientCard(
                  client: client,
                  onEdit: () => showClientDialog(
                    context: context,
                    initial: client,
                    isNew: false,
                    onSave: (updated) =>
                        context.read<ClientsCubit>().editClient(updated),
                  ),
                  onDelete: () =>
                      context.read<ClientsCubit>().deleteClient(client.id),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
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
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
