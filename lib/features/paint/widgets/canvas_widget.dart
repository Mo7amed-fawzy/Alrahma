import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tabea/core/utils/app_colors.dart';
import 'package:tabea/core/utils/custom_text_styles.dart';
import 'package:tabea/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:tabea/features/paint/model/models.dart';
import 'package:tabea/features/paint/widgets/sketch_painter.dart';

class DrawingCanvasWidget extends StatelessWidget {
  final DrawingCanvasCubit cubit;
  final GlobalKey canvasKey;

  const DrawingCanvasWidget({
    super.key,
    required this.cubit,
    required this.canvasKey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _handlePan(details.globalPosition, start: true),
      onPanUpdate: (details) => _handlePan(details.globalPosition),
      onPanEnd: (_) => cubit.endPath(),

      // ✅ اضغط ضغطة واحدة لإضافة نص فقط لو الأداة المختارة "text"
      onTapUp: (details) {
        if (cubit.state.tool == "text") {
          final box = canvasKey.currentContext!.findRenderObject() as RenderBox;
          final local = box.globalToLocal(details.globalPosition);

          // اتأكد إن الضغط مش فوق نص موجود
          final tappedOnText = cubit.state.texts.any((t) {
            final pos = t['position'] as Offset;
            final textSize = (t['size'] as double) * 2; // تقريب حجم النص
            final rect = Rect.fromLTWH(pos.dx, pos.dy, textSize * 2, textSize);
            return rect.contains(local);
          });

          if (!tappedOnText) {
            // cubit.addTextWidget(local);
          }
        }
      },

      child: Container(
        key: canvasKey,
        color: Colors.grey[100],
        child: Stack(
          children: [
            // 🎨 Canvas
            CustomPaint(
              painter: SketchPainter(
                paths: cubit.state.paths
                    .map((e) => PathDataExtension.fromMap(e))
                    .toList(),

                shapes: cubit.state.shapes, // ✅ إضافة shapes هنا
                texts: cubit.state.texts,
              ),
              size: Size.infinite,
            ),

            // 📝 النصوص كـ Widgets
            ...cubit.state.texts.map((t) {
              final pos = t['position'] as Offset;
              return Positioned(
                left: pos.dx,
                top: pos.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    final newPos = pos + details.delta;
                    cubit.updateTextPosition(t, newPos);
                  },
                  onDoubleTap: () => _editText(context, t),
                  child: Card(
                    color: Colors.white,
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        t['text'] ?? '',
                        style: TextStyle(
                          fontSize: t['size'] as double,
                          color: t['color'] as Color,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _handlePan(Offset global, {bool start = false}) {
    final box = canvasKey.currentContext!.findRenderObject() as RenderBox;
    final local = box.globalToLocal(global);

    switch (cubit.state.tool) {
      case "freehand":
      case "line":
        start ? cubit.startPath(local) : cubit.updatePath(local);
        break;

      case "rect":
      case "circle":
        start
            ? cubit.startShape(local, cubit.state.tool)
            : cubit.updateShape(local);
        break;

      default:
        break;
    }
  }

  void _editText(BuildContext context, Map<String, dynamic> textData) async {
    final controller = TextEditingController(text: textData['text']);
    double fontSize = textData['size'] as double;

    final newText = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: AppColors.scaffoldBackground,
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("تعديل النص", style: CustomTextStyles.cairoBold20),
                  SizedBox(height: 12.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 400.w,
                      minWidth: 250.w,
                      maxHeight: 200.h,
                    ),
                    child: TextField(
                      controller: controller,
                      autofocus: true,
                      textAlign: TextAlign.right,
                      maxLines: null,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                        fontSize: fontSize,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: "اكتب النص الجديد",
                        hintStyle: CustomTextStyles.cairoRegular16.copyWith(
                          color: AppColors.mediumGray,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.accentOrange),
                        ),
                      ),
                      onChanged: (val) {
                        // قلّل حجم الخط لو النص طويل
                        final length = val.length;
                        setState(() {
                          if (length > 20) {
                            fontSize = (fontSize - 0.5).clamp(10.0, 100.0);
                          } else if (length < 20) {
                            fontSize = (fontSize + 0.5).clamp(10.0, 100.0);
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "إلغاء",
                          style: CustomTextStyles.cairoSemiBold16.copyWith(
                            color: AppColors.errorRed,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pop(context, controller.text),
                        child: Text("تم", style: CustomTextStyles.buttonText),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (newText != null && newText.isNotEmpty) {
      cubit.updateTextContent(textData, newText);
      cubit.updateTextSize(textData, fontSize); // تحديث الحجم في Cubit
    }
  }
}

extension PathDataExtension on PathData {
  static PathData fromMap(Map<String, dynamic> map) {
    final points = (map['points'] as List<dynamic>? ?? [])
        .map(
          (p) => Offset((p['dx'] ?? 0).toDouble(), (p['dy'] ?? 0).toDouble()),
        )
        .toList();

    final path = Path();

    if (points.isNotEmpty) {
      // 🎯 أول نقطة تصبح نقطة البداية
      path.moveTo(points[0].dx, points[0].dy);

      // باقي النقاط تتوصل بخطوط
      for (var i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    return PathData(
      path: path,
      color: map['color'] as Color? ?? Colors.black,
      width: map['strokeWidth'] as double? ?? 2.0,
    );
  }
}
