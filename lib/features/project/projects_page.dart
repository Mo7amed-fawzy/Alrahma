import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/features/client/card.dart';
import 'package:tabea/features/project/cubit/projects_cubit.dart';
import '../../../../core/database/cache/app_preferences.dart';
import '../../../../core/models/project_model.dart';
import '../../../../core/models/client_model.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/custom_text_styles.dart';

/// BlocProvider موجود قبل عرض الصفحة
class ProjectsPage extends StatelessWidget {
  final AppPreferences projectsPrefs;
  final AppPreferences clientsPrefs;

  const ProjectsPage({
    super.key,
    required this.projectsPrefs,
    required this.clientsPrefs,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectsCubit(
        projectsPrefs: projectsPrefs,
        clientsPrefs: clientsPrefs,
      ),
      child: const ProjectsPageContent(),
    );
  }
}

/// UI منفصل
class ProjectsPageContent extends StatelessWidget {
  const ProjectsPageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProjectsCubit>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المشاريع', style: CustomTextStyles.cairoBold20),
          backgroundColor: AppColors.primaryBlue,
          centerTitle: true,
        ),
        body: BlocBuilder<ProjectsCubit, ProjectsState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.projects.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.business_center_outlined,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد مشاريع بعد',
                      style: CustomTextStyles.cairoRegular18,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: state.projects.length,
              itemBuilder: (context, index) {
                final project = state.projects[index];
                return buildProjectCard(
                  project: project,
                  clients: state.clients,
                  onEdit: () => showProjectDialog(
                    context: context,
                    initial: project,
                    isNew: false,
                    clients: state.clients,
                    onSave: (updated) => cubit.editProject(updated),
                  ),
                  onDelete: () => cubit.deleteProject(project.id),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final id = DateTime.now().millisecondsSinceEpoch.toString();
            showProjectDialog(
              context: context,
              initial: ProjectModel(
                id: id,
                clientId: cubit.state.clients.isNotEmpty
                    ? cubit.state.clients.first.id
                    : '',
                type: '',
                description: '',
                createdAt: DateTime.now(),
              ),
              isNew: true,
              clients: cubit.state.clients,
              onSave: (updated) => cubit.addProject(updated),
            );
          },
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Dialog يستخدم نفس ال helpers بتاع العملاء
Future<void> showProjectDialog({
  required BuildContext context,
  required ProjectModel initial,
  required bool isNew,
  required List<ClientModel> clients,
  required Function(ProjectModel updated) onSave,
}) {
  final typeCtrl = TextEditingController(text: initial.type);
  final descCtrl = TextEditingController(text: initial.description);
  String selectedClientId = initial.clientId;

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNew ? 'إضافة مشروع' : 'تعديل المشروع',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 20),

              // Dropdown لاختيار العميل
              DropdownButtonFormField<String>(
                value: selectedClientId.isEmpty && clients.isNotEmpty
                    ? clients.first.id
                    : selectedClientId,
                items: clients
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          c.name,
                          style: CustomTextStyles.cairoRegular16,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedClientId = v ?? '',
                decoration: const InputDecoration(labelText: 'العميل'),
              ),
              const SizedBox(height: 12),

              // استخدام buildTextField من الـ helpers
              buildTextField(controller: typeCtrl, label: 'النوع'),
              const SizedBox(height: 12),
              buildTextField(controller: descCtrl, label: 'الوصف'),
              const SizedBox(height: 25),

              // أزرار الحفظ والإلغاء بنفس الـ style
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      textStyle: CustomTextStyles.cairoRegular16,
                    ),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final updated = ProjectModel(
                        id: initial.id,
                        clientId: selectedClientId,
                        type: typeCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        createdAt: initial.createdAt,
                      );
                      onSave(updated);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'حفظ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Card للمشروع
Widget buildProjectCard({
  required ProjectModel project,
  required List<ClientModel> clients,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final clientName = clients
      .firstWhere(
        (c) => c.id == project.clientId,
        orElse: () =>
            ClientModel(id: '', name: 'غير معروف', phone: '', address: ''),
      )
      .name;

  return GestureDetector(
    onTap: onEdit,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryGolden.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGolden.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.secondaryGolden,
            child: Text(
              project.type.isNotEmpty ? project.type[0] : '?',
              style: CustomTextStyles.cairoBold20.copyWith(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${project.type} • $clientName',
                  style: CustomTextStyles.cairoBold20,
                ),
                const SizedBox(height: 4),
                Text(
                  project.description,
                  style: CustomTextStyles.cairoRegular16.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    ),
  );
}
