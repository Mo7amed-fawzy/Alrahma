import 'package:alrahma/core/widgets/show_confirm_delete_dialog.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
import 'package:alrahma/features/paint/repository/drawing_repository.dart';
import 'package:alrahma/features/paint/screens/drawing_preview_page.dart';
import 'package:alrahma/features/paint/screens/drawing_canvas_page.dart';
import 'package:alrahma/features/project/cubit/projects_cubit.dart';
import 'package:alrahma/features/project/project_card.dart';
import 'package:alrahma/features/project/widgets/show_project_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/models/client_model.dart';
import '../../core/models/project_model.dart';
import '../../core/models/drawing_model.dart';
import '../../core/utils/app_colors.dart';
import '../../core/utils/custom_text_styles.dart';
import '../../features/client/widgets/funcs/highlight_match.dart';

class ClientProfilePage extends StatelessWidget {
  final ClientModel client;

  const ClientProfilePage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final padding16 = 16.w;
    final avatarRadius = 28.w;
    final iconSize = 28.sp;
    final cardRadius = 20.r;
    final titleFont = 20.sp;
    final subtitleFont = 14.sp;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ProjectsCubit>()),
          BlocProvider.value(
            value: context.read<DrawingsCubit>()..loadDrawings(),
          ), // ← استخدم نفس الـ Cubit
        ],
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            centerTitle: true,
            leading: BackButton(color: Colors.white),
            title: BlocBuilder<ProjectsCubit, ProjectsState>(
              builder: (context, state) {
                final clientProjects = state.projects
                    .where((p) => p.clientId == client.id)
                    .toList();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      client.name,
                      style: CustomTextStyles.cairoBold20.copyWith(
                        fontSize: 22.sp,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.work_outline,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '${clientProjects.length}',
                            style: CustomTextStyles.cairoSemiBold18.copyWith(
                              color: Colors.white,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- Avatar ----------
                Center(
                  child: Hero(
                    tag: 'clientAvatar-${client.id}',
                    child: CircleAvatar(
                      radius: 50.w,
                      backgroundColor: AppColors.primaryBlue,
                      child: Text(
                        client.name.isNotEmpty ? client.name[0] : '?',
                        style: CustomTextStyles.cairoBold24.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),

                // ---------- Client Info ----------
                Column(
                  children: [
                    Center(
                      child: highlightMatch(
                        client.name,
                        null,
                        style: CustomTextStyles.cairoBold20.copyWith(
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Center(
                      child: highlightMatch(
                        '${client.phone} • ${client.address}',
                        null,
                        style: CustomTextStyles.cairoRegular16.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),

                // ---------- Projects ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('المشاريع', style: CustomTextStyles.cairoSemiBold18),
                    IconButton(
                      icon: Icon(Icons.add, color: AppColors.primaryBlue),
                      onPressed: () {
                        final id = DateTime.now().millisecondsSinceEpoch
                            .toString();
                        final cubit = context.read<ProjectsCubit>();
                        showProjectDialog(
                          context: context,
                          initial: ProjectModel(
                            id: id,
                            clientId: client.id, // 👈 يتثبت هنا
                            type: '',
                            description: '',
                            createdAt: DateTime.now(),
                          ),
                          isNew: true,
                          clients: cubit.state.clients,
                          fixedClient: client, // 👈 هنا
                          onSave: (updated) {
                            cubit.addProject(updated);
                          },
                        );
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                BlocBuilder<ProjectsCubit, ProjectsState>(
                  builder: (context, state) {
                    final clientProjects = state.projects
                        .where((p) => p.clientId == client.id)
                        .toList();

                    if (clientProjects.isEmpty) {
                      return Center(
                        child: Text(
                          'لا يوجد مشاريع',
                          style: CustomTextStyles.cairoRegular16.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: clientProjects.length,
                      itemBuilder: (context, index) {
                        final project = clientProjects[index];
                        return buildProjectCard(
                          project: project,
                          clients: state.clients,
                          screenWidth: MediaQuery.of(context).size.width,
                          onEdit: () {
                            showProjectDialog(
                              context: context,
                              initial: project,
                              isNew: false,
                              clients: state.clients,
                              fixedClient: client, // 👈 هنا برضه
                              onSave: (updated) => context
                                  .read<ProjectsCubit>()
                                  .editProject(updated),
                            );
                          },
                          onDelete: () async {
                            final confirmed = await showConfirmDeleteDialog(
                              context,
                              itemName: project.type,
                            );
                            if (confirmed == true) {
                              context.read<ProjectsCubit>().deleteProject(
                                project.id,
                              );

                              // تصفية الرسومات التابعة للمشروع المحذوف
                              context.read<DrawingsCubit>().deleteDrawing(
                                project.id,
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),

                // ---------- Drawings ----------
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الرسومات', style: CustomTextStyles.cairoSemiBold18),
                    IconButton(
                      icon: Icon(Icons.add, color: AppColors.primaryBlue),
                      onPressed: () async {
                        final drawingsCubit = context.read<DrawingsCubit>();
                        final projectsCubit = context.read<ProjectsCubit>();
                        final clientProjects = projectsCubit.state.projects
                            .where((p) => p.clientId == client.id)
                            .toList();

                        if (clientProjects.isEmpty) {
                          SnackbarHelper.show(
                            context,
                            message: '⚠️ لا يوجد مشاريع لإضافة رسمة',
                            backgroundColor: AppColors.primaryBlue,
                          );
                          return;
                        }

                        // فتح صفحة الرسم والانتظار حتى يتم الإغلاق
                        // final jsonDataAndProjectId =
                        //     await Navigator.push<Map<String, String>>(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (_) => DrawingCanvasPage(
                        //           projects: clientProjects, // ✅ هنا
                        //           // onSave: (jsonData, projectId) {
                        //           //   // نرجع البيانات عند الحفظ
                        //           //   Navigator.pop(context, {
                        //           //     'jsonData': jsonData,
                        //           //     'projectId': projectId,
                        //           //   });
                        //           // },
                        //           onSave: (drawing) {
                        //             Navigator.pop(context, drawing);
                        //           },
                        final newDrawing = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            // builder: (ctx) => RepositoryProvider.value(
                            // value: context.read<DrawingRepository>(),
                            builder: (ctx) => BlocProvider(
                              create: (_) =>
                                  DrawingCanvasCubit(projects: clientProjects),
                              child: DrawingCanvasPage(
                                projects: clientProjects,
                                onSave: (drawing) {
                                  Navigator.pop(context, drawing);
                                },
                                repository: context
                                    .read<DrawingRepository>(), // ✅ مرره هنا
                              ),
                            ),
                            // ),
                          ),
                        );

                        // لو المستخدم حفظ الرسمة بالفعل
                        // if (jsonDataAndProjectId != null) {
                        //   final id = DateTime.now().millisecondsSinceEpoch
                        //       .toString();
                        //   final model = DrawingModel(
                        //     id: id,
                        //     projectId: jsonDataAndProjectId['projectId']!,
                        //     title: "رسمة جديدة",
                        //     dataJson: jsonDataAndProjectId['jsonData']!,
                        //     createdAt: DateTime.now(),
                        //   );
                        //   drawingsCubit.addDrawing(model);
                        if (newDrawing != null) {
                          drawingsCubit.addDrawing(newDrawing);

                          SnackbarHelper.show(
                            context,
                            message: 'تم حفظ الرسمة بنجاح',
                            backgroundColor: AppColors.primaryBlue,
                          );
                        }
                      },
                    ),
                  ],
                ),

                SizedBox(height: 12.h),
                BlocBuilder<DrawingsCubit, DrawingsState>(
                  builder: (context, state) {
                    final drawingsCubit = context
                        .read<DrawingsCubit>(); // ✅ هنا عرفنا الـ cubit
                    final drawings = state.drawings;
                    final projectsCubit = context.read<ProjectsCubit>();
                    final clientProjects = projectsCubit.state.projects
                        .where((p) => p.clientId == client.id)
                        .toList();

                    final clientDrawings = drawings.where((d) {
                      return clientProjects.any((p) => p.id == d.projectId);
                    }).toList();

                    if (clientDrawings.isEmpty) {
                      return Center(
                        child: Text(
                          'لا يوجد رسومات',
                          style: CustomTextStyles.cairoRegular16.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: clientDrawings.length,
                      separatorBuilder: (_, __) => SizedBox(height: 14.h),
                      itemBuilder: (context, index) {
                        final d = clientDrawings[index];
                        final project = clientProjects.firstWhere(
                          (p) => p.id == d.projectId,
                          orElse: () => ProjectModel(
                            id: '',
                            clientId: '',
                            type: 'مشروع غير معروف',
                            description: '',
                            createdAt: DateTime.now(),
                          ),
                        );
                        // itemBuilder: (context, index) {
                        //   final d = clientDrawings[index]; // ← ده DrawingModel واحد
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RepositoryProvider.value(
                                  value: context.read<DrawingRepository>(),
                                  child: MultiBlocProvider(
                                    providers: [
                                      BlocProvider.value(value: drawingsCubit),
                                      BlocProvider(
                                        create: (_) => DrawingCanvasCubit(
                                          projects: clientProjects,
                                          existingDrawing: d,
                                        )..loadImagesForDrawing(d),
                                      ),
                                    ],
                                    child: DrawingPreviewPage(
                                      drawingId: d.id,
                                      projects: clientProjects,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cardRadius),
                            ),
                            elevation: 4,
                            shadowColor: Colors.lightBlue.withOpacity(0.25),
                            child: Padding(
                              padding: EdgeInsets.all(padding16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: avatarRadius,
                                    backgroundColor: AppColors.primaryBlue
                                        .withOpacity(0.2),
                                    child: Icon(
                                      Icons.brush,
                                      color: Colors.lightBlue,
                                      size: iconSize,
                                    ),
                                  ),
                                  SizedBox(width: 16.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          project.type,
                                          style: CustomTextStyles.cairoBold20
                                              .copyWith(fontSize: titleFont),
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          "📅 ${d.createdAt.year}/${d.createdAt.month.toString().padLeft(2, '0')}/${d.createdAt.day.toString().padLeft(2, '0')}",
                                          style: CustomTextStyles.cairoRegular14
                                              .copyWith(
                                                color: Colors.grey[600],
                                                fontSize: subtitleFont,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                      size: iconSize,
                                    ),
                                    onPressed: () async {
                                      final confirmed =
                                          await showConfirmDeleteDialog(
                                            context,
                                            itemName: project.type,
                                          );

                                      if (confirmed == true) {
                                        drawingsCubit.deleteDrawing(d.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
