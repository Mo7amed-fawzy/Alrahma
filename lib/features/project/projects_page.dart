import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/features/client/card.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
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
            ),
          ),
          backgroundColor: AppColors.secondaryGolden,
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
                  onDelete: () => cubit.deleteProject(project.id),
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
          backgroundColor: AppColors.secondaryGolden,
          child: Icon(Icons.add, size: screenWidth * 0.08),
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
  final screenWidth = MediaQuery.of(context).size.width;
  final typeCtrl = TextEditingController(text: initial.type);
  final descCtrl = TextEditingController(text: initial.description);
  String selectedClientId = initial.clientId;

  return showDialog(
    context: context,
    builder: (_) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      elevation: 10,
      backgroundColor: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNew ? 'إضافة مشروع' : 'تعديل المشروع',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: AppColors.secondaryGolden,
                  fontSize: screenWidth * 0.05,
                ),
              ),
              SizedBox(height: screenWidth * 0.05),

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
                          style: CustomTextStyles.cairoRegular16.copyWith(
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedClientId = v ?? '',
                decoration: InputDecoration(
                  labelText: 'العميل',
                  labelStyle: TextStyle(
                    fontSize: screenWidth * 0.045,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.03),

              // استخدام buildTextField من الـ helpers
              buildTextField(
                controller: typeCtrl,
                label: 'النوع',
                // fontSize: screenWidth * 0.045,
              ),
              SizedBox(height: screenWidth * 0.03),
              buildTextField(
                controller: descCtrl,
                label: 'الوصف',
                // fontSize: screenWidth * 0.045,
              ),
              SizedBox(height: screenWidth * 0.05),

              // أزرار الحفظ والإلغاء بنفس الـ style
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      textStyle: TextStyle(fontSize: screenWidth * 0.043),
                    ),
                    child: const Text('إلغاء'),
                  ),
                  SizedBox(width: screenWidth * 0.03),
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
                      SnackbarHelper.show(
                        context,
                        message: " تم حفظ المشروع بنجاح",
                        backgroundColor: AppColors.secondaryGolden,
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondaryGolden,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenWidth * 0.035,
                      ),
                    ),
                    child: Text(
                      'حفظ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.045,
                      ),
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
  required double screenWidth,
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
      margin: EdgeInsets.symmetric(
        vertical: screenWidth * 0.02,
        horizontal: screenWidth * 0.01,
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.secondaryGolden.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondaryGolden.withValues(alpha: 0.2),
            blurRadius: screenWidth * 0.02,
            offset: Offset(0, screenWidth * 0.01),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: screenWidth * 0.12,
            height: screenWidth * 0.12,
            child: CircleAvatar(
              backgroundColor: AppColors.secondaryGolden,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  project.type.isNotEmpty ? project.type[0] : '?',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${project.type} • $clientName',
                  style: CustomTextStyles.cairoBold20.copyWith(
                    fontSize: screenWidth * 0.045,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  project.description,
                  style: CustomTextStyles.cairoRegular16.copyWith(
                    color: Colors.grey[700],
                    fontSize: screenWidth * 0.04,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: screenWidth * 0.07,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    ),
  );
}
