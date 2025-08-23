import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/core/models/project_model.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_state.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'package:tabea/features/paint/widgets/canvas_widget.dart';
import 'package:tabea/features/paint/widgets/project_selector.dart';
import 'package:tabea/features/paint/widgets/toolbar.dart';

class DrawingCanvasPage extends StatelessWidget {
  final void Function(String jsonData, String projectId) onSave;
  final List<ProjectModel> projects;
  final String? initialData; // ✅ إضافة متغير لتمرير الرسمة المحفوظة
  final GlobalKey _canvasKey = GlobalKey();

  DrawingCanvasPage({
    super.key,
    required this.onSave,
    required this.projects,
    this.initialData, // استقبال الرسمة المحفوظة
  });

  void _save(BuildContext context) {
    final cubit = context.read<DrawingCanvasCubit>();
    onSave(cubit.exportJson(), cubit.state.selectedProjectId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DrawingCanvasCubit(
        projects,
        initialData: initialData,
      ), // تمرير البيانات عند الإنشاء
      child: BlocBuilder<DrawingCanvasCubit, DrawingCanvasState>(
        builder: (context, state) {
          final cubit = context.read<DrawingCanvasCubit>();
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text("لوحة الرسم"),
                backgroundColor: AppColors.accentOrange,
                centerTitle: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                actions: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.undo),
                        tooltip: "Undo",
                        onPressed: cubit.undo,
                      ),
                      IconButton(
                        icon: const Icon(Icons.redo),
                        tooltip: "Redo",
                        onPressed: cubit.redo,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_forever,
                      color: Colors.redAccent,
                    ),
                    onPressed: cubit.clear,
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _save(context),
                  ),
                ],
              ),
              body: Column(
                children: [
                  ProjectSelector(
                    cubit: cubit,
                    projects: state.projects,
                    selectedProjectId: state.selectedProjectId,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: DrawingToolbar(
                      cubit: cubit,
                      strokeWidth: state.strokeWidth,
                      onStrokeChanged: cubit.changeStrokeWidth,
                    ),
                  ),
                  Expanded(
                    child: DrawingCanvasWidget(
                      cubit: context.read<DrawingCanvasCubit>(),
                      canvasKey: _canvasKey,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
