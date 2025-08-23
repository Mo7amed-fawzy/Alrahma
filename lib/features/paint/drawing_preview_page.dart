import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tabea/core/models/drawing_model.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_state.dart';
import 'package:tabea/features/paint/cubit/drawings_cubit.dart';
import 'package:tabea/features/paint/drawing_canvas_page.dart';
import 'package:tabea/features/paint/widgets/canvas_widget.dart';
import 'package:tabea/features/paint/widgets/sketch_painter.dart';
import 'package:tabea/features/paint/model/models.dart';

class DrawingPreviewPage extends StatelessWidget {
  final DrawingModel drawing;

  const DrawingPreviewPage({super.key, required this.drawing});

  @override
  Widget build(BuildContext context) {
    // تحويل الـ JSON المخزن إلى مسارات، أشكال ونصوص
    final Map<String, dynamic> jsonData = jsonDecode(drawing.drawingData);

    final paths =
        (jsonData['paths'] as List<dynamic>?)
            ?.map(
              (e) => PathDataExtension.fromMap(Map<String, dynamic>.from(e)),
            )
            .toList() ??
        [];

    final shapes =
        (jsonData['shapes'] as List<dynamic>?)
            ?.map((s) => ShapeData.fromMap(Map<String, dynamic>.from(s)))
            .toList() ??
        [];

    final texts =
        (jsonData['texts'] as List<dynamic>?)
            ?.map((t) => Map<String, dynamic>.from(t))
            .toList() ??
        [];

    // إنشاء Cubit للمعاينة (Read-Only)
    final cubit = DrawingCanvasCubit.preview(
      paths: paths
          .map((p) => p.toMap())
          .toList(), // paths: List<Map<String,dynamic>> ✅
      shapes: shapes, // shapes: List<ShapeData> ✅
      texts: texts,
    );

    return BlocProvider.value(
      value: cubit,
      child: BlocBuilder<DrawingCanvasCubit, DrawingCanvasState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("معاينة الرسمة"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DrawingCanvasPage(
                          projects: context
                              .read<DrawingCanvasCubit>()
                              .state
                              .projects,
                          onSave: (jsonData, projectId) {
                            final updatedDrawing = DrawingModel(
                              id: drawing.id,
                              projectId: projectId,
                              drawingData: jsonData,
                              createdAt: drawing.createdAt,
                            );
                            // حفظ التعديلات
                            context.read<DrawingCanvasCubit>().updateDrawing(
                              updatedDrawing,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: InteractiveViewer(
              child: Container(
                color: Colors.white,
                child: CustomPaint(
                  painter: SketchPainter(
                    paths: state.paths
                        .map((e) => PathDataExtension.fromMap(e))
                        .toList(),
                    shapes: state.shapes, // ✅ مباشرة
                    texts: state.texts,
                  ),
                  size: Size.infinite,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------
// Extensions لتحويل PathData و ShapeData إلى Map
// -----------------------------
extension PathDataMap on PathData {
  Map<String, dynamic> toMap() {
    // تحويل الـ Path إلى قائمة نقاط
    final points = <Map<String, double>>[];
    // إذا عندك طريقة لحفظ النقاط الأصلية، ضيفها هنا
    return {'points': points, 'color': color.value, 'strokeWidth': width};
  }
}

extension ShapeDataMap on ShapeData {
  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'rect': rect == null
          ? null
          : {
              'left': rect!.left,
              'top': rect!.top,
              'width': rect!.width,
              'height': rect!.height,
            },
      'center': center == null ? null : {'dx': center!.dx, 'dy': center!.dy},
      'radius': radius,
      'color': color.value,
      'strokeWidth': strokeWidth,
    };
  }
}
