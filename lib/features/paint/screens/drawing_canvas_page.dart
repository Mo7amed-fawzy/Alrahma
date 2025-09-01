import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/components/canvas_widget.dart';
import 'package:alrahma/features/paint/components/project_selector.dart';
import 'package:alrahma/features/paint/components/toolbar.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_state.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';

class DrawingCanvasPage extends StatelessWidget {
  final List<ProjectModel> projects;
  final Function(String jsonData, String projectId) onSave;
  final DrawingModel? existingDrawing;

  const DrawingCanvasPage({
    super.key,
    required this.projects,
    required this.onSave,
    this.existingDrawing,
  });

  bool get isEditing => existingDrawing != null; // ← صحيح هنا

  @override
  Widget build(BuildContext context) {
    final sizedBox8 = 8.h;
    final appBarRadius = 16.r;
    final titleFont = 20.sp;
    final iconSplash = 24.r;

    return BlocProvider(
      create: (_) => DrawingCanvasCubit(
        projects: projects,
        existingDrawing: existingDrawing,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "لوحة الرسم",
            style: CustomTextStyles.cairoBold20.copyWith(
              color: Colors.white,
              fontSize: titleFont,
            ),
          ),
          backgroundColor: AppColors.accentOrange,
          elevation: 4,
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(appBarRadius),
            ),
          ),
          actions: [
            BlocBuilder<DrawingCanvasCubit, DrawingCanvasState>(
              builder: (context, state) {
                final cubit = context.read<DrawingCanvasCubit>();
                return IconButton(
                  icon: const Icon(Icons.save),
                  tooltip: "حفظ الرسم",
                  color: Colors.white,
                  splashRadius: iconSplash,
                  onPressed: () {
                    if (state.selectedProjectId.isEmpty) {
                      SnackbarHelper.show(
                        context,
                        message: " الرجاء اختيار مشروع قبل الحفظ",
                      );
                      return;
                    }

                    final drawing = DrawingModel(
                      id:
                          existingDrawing?.id ??
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      projectId: state.selectedProjectId,
                      title: existingDrawing?.title ?? "رسمة جديدة",
                      paths: cubit.state.currentPaths,
                      shapes: cubit.state.shapes,
                      texts: cubit.state.textData,
                      selectedColor: cubit.state.selectedColor,
                      strokeWidth: cubit.state.strokeWidth,
                      tool: cubit.state.tool,
                      createdAt: existingDrawing?.createdAt ?? DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    final jsonData = drawing.toJson();

                    // إعادة JSON للرابط اللي استدعى الصفحة (Preview أو أي مكان آخر)
                    onSave(jsonData, state.selectedProjectId);

                    // إغلاق الصفحة بعد الحفظ
                    Navigator.pop(context, jsonData);
                  },
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<DrawingCanvasCubit, DrawingCanvasState>(
          builder: (context, state) {
            final cubit = context.read<DrawingCanvasCubit>();

            return Column(
              children: [
                SizedBox(height: sizedBox8),
                ProjectSelector(
                  cubit: cubit,
                  projects: projects,
                  selectedProjectId: state.selectedProjectId,
                  isEditing: isEditing, // ← جديد
                ),

                SizedBox(height: sizedBox8),
                DrawingToolbar(
                  cubit: cubit,
                  strokeWidth: state.strokeWidth,
                  onStrokeChanged: (value) => cubit.changeStrokeWidth(value),
                ),
                SizedBox(height: sizedBox8),
                Expanded(
                  child: Container(
                    color: Colors.grey.shade200,
                    child: const DrawingCanvasWidget(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
