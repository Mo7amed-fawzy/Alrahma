import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/features/paint/logic/sketch_painter.dart';
import 'package:alrahma/features/paint/screens/drawing_canvas_page.dart';
import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';

class DrawingPreviewPage extends StatelessWidget {
  final DrawingModel drawing;
  final List<ProjectModel> projects;
  final Function(DrawingModel updated)? onUpdate; // ← جديد

  const DrawingPreviewPage({
    super.key,
    required this.drawing,
    required this.projects,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final paths = drawing.paths;
    final shapes = drawing.shapes;
    final texts = drawing.texts;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "معاينة الرسمة",
            style: CustomTextStyles.cairoBold20.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.accentOrange,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              tooltip: "تعديل الرسمة",
              onPressed: () async {
                // فتح صفحة الرسم للتعديل
                final updatedJson = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DrawingCanvasPage(
                      projects: projects,
                      existingDrawing: drawing,
                      onSave: (jsonData, projectId) {
                        Navigator.pop(context, jsonData); // نرجع JSON فقط
                      },
                    ),
                  ),
                );

                if (updatedJson != null && onUpdate != null) {
                  // تحويل JSON مرة أخرى إلى DrawingModel كامل
                  final updatedDrawing = DrawingModel.fromJson(updatedJson);

                  // لو محتاج تحافظ على projectId و title من الرسم الأصلي
                  final finalDrawing = updatedDrawing.copyWith(
                    projectId: drawing.projectId,
                    title: drawing.title,
                    updatedAt: DateTime.now(),
                  );

                  // تمرير الرسم المحدث للمستدعي
                  onUpdate!(finalDrawing);

                  SnackbarHelper.show(
                    context,
                    message: "تم تحديث الرسمة بنجاح",
                  );
                }
              },
            ),
          ],
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1.0,
            maxScale: 5.0,
            child: RepaintBoundary(
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                shadowColor: Colors.orange.withOpacity(0.25),
                child: Container(
                  width: 1000,
                  height: 1000,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: SketchPainter(
                      paths: paths,
                      shapes: shapes,
                      texts: texts,
                      originalSize: const Size(1000, 1000),
                      scale: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
