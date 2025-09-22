import 'package:alrahma/core/widgets/show_confirm_delete_dialog.dart';
import 'package:alrahma/features/project/project_card.dart';
import 'package:alrahma/features/project/widgets/show_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:alrahma/features/project/cubit/projects_cubit.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'المشاريع',
            style: CustomTextStyles.cairoBold20.copyWith(
              fontSize: screenWidth * 0.05,
              color: Colors.white, // نص أبيض ليتباين مع primaryBlue
            ),
          ),
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
                      size: screenWidth * 0.2,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: screenWidth * 0.05),
                    Text(
                      'لا توجد مشاريع بعد',
                      style: CustomTextStyles.cairoRegular18.copyWith(
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.03,
              ),
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
                  onDelete: () async {
                    // جلب العميل المرتبط بالمشروع
                    final client = state.clients.firstWhere(
                      (c) => c.id == project.clientId,
                      orElse: () => ClientModel(
                        id: '',
                        name: 'عميل غير معروف',
                        phone: '',
                        address: '',
                      ),
                    );

                    final confirmed = await showConfirmDeleteDialog(
                      context,
                      itemName:
                          '${project.type} • ${client.name}', // اسم المشروع + اسم العميل
                    );

                    if (confirmed == true) {
                      cubit.deleteProject(project.id);
                    }
                  },

                  screenWidth: screenWidth,
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
          child: Icon(Icons.add, size: screenWidth * 0.08),
        ),
      ),
    );
  }
}
