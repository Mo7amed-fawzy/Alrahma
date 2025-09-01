import 'package:alrahma/core/widgets/show_confirm_delete_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/models/client_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
import 'package:alrahma/features/paint/screens/drawing_canvas_page.dart';
import 'package:alrahma/features/paint/screens/drawing_preview_page.dart';
import '../../../../core/models/drawing_model.dart';

class DrawingsPage extends StatelessWidget {
  const DrawingsPage({super.key});

  void _addDrawing(
    BuildContext context,
    List<ProjectModel> projects,
    List<ClientModel> clients,
  ) {
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا يوجد مشاريع لإضافة رسمة')),
      );
      return;
    }

    final cubit = context.read<DrawingsCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrawingCanvasPage(
          projects: projects,
          onSave: (jsonData, projectId) async {
            final id = DateTime.now().millisecondsSinceEpoch.toString();
            final model = DrawingModel(
              id: id,
              projectId: projectId,
              title: "رسمة جديدة",
              dataJson: jsonData,
              createdAt: DateTime.now(),
            );
            cubit.addDrawing(model);

            SnackbarHelper.show(context, message: " تم حفظ الرسمة بنجاح");
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding16 = 16.w;
    final padding32 = 32.w;
    final avatarRadius = 28.w;
    final iconSize = 28.sp;
    final cardRadius = 20.r;
    final fabRadius = 16.r;
    final titleFont = 20.sp;
    final subtitleFont = 14.sp;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<DrawingsCubit, DrawingsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(
                'الرسومات',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: Colors.white,
                  fontSize: titleFont,
                ),
              ),
              backgroundColor: AppColors.accentOrange,
              centerTitle: true,
              elevation: 4,
              shadowColor: Colors.orange.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24.r),
                ),
              ),
            ),
            body: state.drawings.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(padding32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 24.h),
                          Text(
                            'لا يوجد رسومات بعد 🎨',
                            style: CustomTextStyles.cairoBold20.copyWith(
                              color: Colors.grey[700],
                              fontSize: titleFont,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            "ابدأ أول رسمة الآن بالضغط على الزر أسفل 👇",
                            style: CustomTextStyles.cairoRegular14.copyWith(
                              color: Colors.grey[600],
                              fontSize: subtitleFont,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.all(padding16),
                    itemCount: state.drawings.length,
                    separatorBuilder: (_, __) => SizedBox(height: 14.h),
                    itemBuilder: (context, i) {
                      final d = state.drawings[i];

                      final project = state.projects.firstWhere(
                        (e) => e.id == d.projectId,
                        orElse: () => ProjectModel(
                          id: '',
                          clientId: '',
                          type: 'مشروع غير معروف',
                          description: '',
                          createdAt: DateTime.now(),
                        ),
                      );

                      final client = state.clients?.firstWhere(
                        (c) => c.id == project.clientId,
                        orElse: () => ClientModel(
                          id: '',
                          name: 'عميل غير معروف',
                          phone: '',
                          address: '',
                        ),
                      );

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context
                                    .read<
                                      DrawingsCubit
                                    >(), // إعادة استخدام Cubit الموجود
                                child: DrawingPreviewPage(
                                  drawing: d,
                                  projects: state
                                      .projects, // ← استخدم state.projects هنا
                                  onUpdate: (updatedDrawing) {
                                    // تحديث الرسم مباشرة عبر Cubit
                                    context.read<DrawingsCubit>().updateDrawing(
                                      updatedDrawing,
                                    );
                                  },
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
                          shadowColor: Colors.orange.withOpacity(0.25),
                          child: Padding(
                            padding: EdgeInsets.all(padding16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: avatarRadius,
                                  backgroundColor: AppColors.accentOrange
                                      .withOpacity(0.2),
                                  child: Icon(
                                    Icons.brush,
                                    color: Colors.orange,
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
                                        "👤 ${client?.name ?? 'عميل غير معروف'}",
                                        style: CustomTextStyles.cairoRegular14
                                            .copyWith(
                                              color: Colors.grey[700],
                                              fontSize: subtitleFont,
                                            ),
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
                                    final confirmed = await showConfirmDeleteDialog(
                                      context,
                                      itemName:
                                          '${project.type} • ${client?.name ?? 'عميل غير معروف'}',
                                    );

                                    if (confirmed == true) {
                                      context
                                          .read<DrawingsCubit>()
                                          .deleteDrawing(d.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () =>
                  _addDrawing(context, state.projects, state.clients ?? []),
              backgroundColor: AppColors.accentOrange,
              icon: Icon(Icons.add, color: Colors.white, size: iconSize),
              label: Text(
                "إضافة رسمة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: subtitleFont,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(fabRadius),
              ),
            ),
          );
        },
      ),
    );
  }
}
