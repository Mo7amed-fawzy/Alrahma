import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/core/models/project_model.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'package:tabea/core/utils/custom_text_styles.dart';
import 'package:tabea/features/paint/cubit/drawings_cubit.dart';
import 'package:tabea/features/paint/drawing_canvas_page.dart';
import 'package:tabea/features/paint/drawing_preview_page.dart';
import '../../../core/models/drawing_model.dart';

class DrawingsPage extends StatelessWidget {
  const DrawingsPage({super.key});

  void _addDrawing(BuildContext context, List<ProjectModel> projects) {
    if (projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ لا يوجد مشاريع لإضافة رسمة')),
      );
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final cubit = context.read<DrawingsCubit>();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DrawingCanvasPage(
          onSave: (jsonData, projectId) async {
            final model = DrawingModel(
              id: id,
              projectId: projectId,
              drawingData: jsonData,
              createdAt: DateTime.now(),
            );
            cubit.addDrawing(model);

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("✅ تم حفظ الرسمة بنجاح")),
            );
          },
          projects: projects,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocBuilder<DrawingsCubit, DrawingsState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            appBar: AppBar(
              title: Text(
                ' الرسومات',
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: Colors.white,
                ),
              ),
              backgroundColor: AppColors.accentOrange,
              centerTitle: true,
              elevation: 4,
              shadowColor: Colors.orange.withOpacity(0.4),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
            ),

            // 🖼️ حالة لو مفيش رسومات
            body: state.drawings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Image.asset(
                          //   "assets/images/empty_drawings.png",
                          //   height: 160,
                          // ),
                          const SizedBox(height: 24),
                          Text(
                            'لا يوجد رسومات بعد 🎨',
                            style: CustomTextStyles.cairoBold20.copyWith(
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "ابدأ أول رسمة الآن بالضغط على الزر أسفل 👇",
                            style: CustomTextStyles.cairoRegular14.copyWith(
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                // 📋 قائمة الرسومات
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.drawings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final d = state.drawings[i];
                      final p = state.projects.firstWhere(
                        (e) => e.id == d.projectId,
                        orElse: () => ProjectModel(
                          id: '',
                          clientId: '',
                          type: 'غير معروف',
                          description: '',
                          createdAt: DateTime.now(),
                        ),
                      );

                      return GestureDetector(
                        onTap: () {
                          if (state.projects.isEmpty) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider.value(
                                value: context.read<DrawingsCubit>(),
                                child: DrawingPreviewPage(drawing: d),
                              ),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                            shadowColor: Colors.orange.withOpacity(0.25),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundColor: AppColors.accentOrange
                                        .withOpacity(0.2),
                                    child: const Icon(
                                      Icons.brush,
                                      color: Colors.orange,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.type,
                                          style: CustomTextStyles.cairoBold20,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "📅 ${d.createdAt.year}/${d.createdAt.month.toString().padLeft(2, '0')}/${d.createdAt.day.toString().padLeft(2, '0')}",
                                          style: CustomTextStyles.cairoRegular14
                                              .copyWith(
                                                color: Colors.grey[600],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.redAccent,
                                    ),
                                    onPressed: () => context
                                        .read<DrawingsCubit>()
                                        .deleteDrawing(i),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

            // ➕ زر إضافة رسمة
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _addDrawing(context, state.projects),
              backgroundColor: AppColors.accentOrange,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "إضافة رسمة",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}
