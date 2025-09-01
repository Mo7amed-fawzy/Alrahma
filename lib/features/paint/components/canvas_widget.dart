import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_state.dart';
import 'package:alrahma/features/paint/logic/sketch_painter.dart';
import 'package:alrahma/features/paint/logic/to_localIn_zoom.dart';
import 'package:alrahma/features/paint/widgets/canvas_text_dialog.dart';

class DrawingCanvasWidget extends StatefulWidget {
  const DrawingCanvasWidget({super.key});

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  List<Offset> currentPoints = [];
  Offset? startShape;

  // للتحريك والتكبير (HandTool)
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _startFocalPoint = Offset.zero;
  double _previousScale = 1.0;
  Offset _previousOffset = Offset.zero;

  // تحديد حدود الرسم (Sketch)
  final Rect sketchRect = Rect.fromLTWH(0, 0, 1000, 1000);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocBuilder<DrawingCanvasCubit, DrawingCanvasState>(
      builder: (context, state) {
        final cubit = context.read<DrawingCanvasCubit>();

        return GestureDetector(
          onDoubleTapDown: (details) async {
            if (state.tool == "text") {
              final result = await showAddTextDialog(context);

              if (result != null) {
                // تحويل القيمة لـ double قبل استدعاء .sp
                final fontSize = (result["fontSize"] != null
                    ? (result["fontSize"] as num).toDouble().sp
                    : 18.sp);

                final position = toTextLocalPosition(
                  context,
                  details.globalPosition,
                  _offset,
                  _scale,
                  result["text"],
                  fontSize: fontSize,
                );

                // حصر النص داخل حدود السكتش
                final clampedPosition = Offset(
                  position.dx.clamp(sketchRect.left, sketchRect.right),
                  position.dy.clamp(sketchRect.top, sketchRect.bottom),
                );

                cubit.addText(
                  result["text"],
                  position: clampedPosition,
                  color: state.selectedColor,
                  fontSize: fontSize,
                  hasBackground: result["hasBackground"] ?? false,
                  backgroundColor: result["backgroundColor"],
                );
              }
            }
          },

          onScaleStart: (details) {
            if (state.isHandTool) {
              _startFocalPoint = details.focalPoint;
              _previousOffset = _offset;
              _previousScale = _scale;
            } else {
              final pos = toLocalInZoom(
                context,
                details.focalPoint,
                _offset,
                _scale,
              );
              if (state.tool == "freehand" || state.tool == "line") {
                currentPoints = [pos];
              } else if (state.tool == "rect" || state.tool == "circle") {
                startShape = pos;
                currentPoints = [pos];
              }
            }
          },

          onScaleUpdate: (details) {
            if (state.isHandTool) {
              setState(() {
                _scale = (_previousScale * details.scale).clamp(0.5, 5.0);
                _offset =
                    _previousOffset + (details.focalPoint - _startFocalPoint);
              });
            } else {
              final pos = toLocalInZoom(
                context,
                details.focalPoint,
                _offset,
                _scale,
              );

              // حصر النقطة داخل حدود السكتش
              final clampedPos = Offset(
                pos.dx.clamp(sketchRect.left, sketchRect.right),
                pos.dy.clamp(sketchRect.top, sketchRect.bottom),
              );

              setState(() {
                if (state.tool == "eraser") {
                  cubit.eraseAtPosition(clampedPos);
                } else if (state.tool == "freehand" || state.tool == "line") {
                  currentPoints.add(clampedPos);
                } else if (state.tool == "rect" || state.tool == "circle") {
                  if (currentPoints.isEmpty) {
                    currentPoints = [startShape!, clampedPos];
                  } else {
                    currentPoints[currentPoints.length - 1] = clampedPos;
                  }
                }
              });
            }
          },

          onScaleEnd: (details) {
            if (!state.isHandTool) {
              if (state.tool == "freehand") {
                _addHandPath(cubit, state);
              } else if (state.tool == "line") {
                _addLinePath(cubit, state);
              } else if ((state.tool == "rect" || state.tool == "circle") &&
                  startShape != null &&
                  currentPoints.isNotEmpty) {
                final endPos = currentPoints.last;

                // حصر النقطة داخل حدود السكتش
                final clampedEnd = Offset(
                  endPos.dx.clamp(sketchRect.left, sketchRect.right),
                  endPos.dy.clamp(sketchRect.top, sketchRect.bottom),
                );

                if (state.tool == "rect") {
                  cubit.addShape(
                    ShapeData.rect(
                      start: startShape!,
                      end: clampedEnd,
                      color: state.selectedColor,
                      strokeWidth: state.strokeWidth.sp,
                    ),
                  );
                } else {
                  final radius = (clampedEnd - startShape!).distance / 2;
                  final center = Offset(
                    (startShape!.dx + clampedEnd.dx) / 2,
                    (startShape!.dy + clampedEnd.dy) / 2,
                  );
                  cubit.addShape(
                    ShapeData.circle(
                      center: center,
                      radius: radius,
                      color: state.selectedColor,
                      strokeWidth: state.strokeWidth.sp,
                    ),
                  );
                }
                startShape = null;
              }

              currentPoints = [];
            }
          },

          child: Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            child: ClipRect(
              child: CustomPaint(
                painter: SketchPainter(
                  paths:
                      state.currentPaths +
                      ((state.tool == "freehand" || state.tool == "line") &&
                              currentPoints.isNotEmpty
                          ? [
                              PathData(
                                points: currentPoints,
                                color: state.selectedColor,
                                strokeWidth: state.strokeWidth.sp,
                              ),
                            ]
                          : []),
                  shapes: state.shapes,
                  texts: state.textData,
                  originalSize: const Size(1000, 1000),
                  offset: _offset,
                  scale: _scale,
                  startShape: startShape,
                  currentShapePoints: currentPoints,
                  cubit: cubit,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
        );
      },
    );
  }

  void _addHandPath(DrawingCanvasCubit cubit, DrawingCanvasState state) {
    if (currentPoints.isNotEmpty) {
      cubit.addPath(
        PathData(
          points: currentPoints,
          color: state.selectedColor,
          strokeWidth: state.strokeWidth.sp,
        ),
      );
    }
  }

  void _addLinePath(DrawingCanvasCubit cubit, DrawingCanvasState state) {
    if (currentPoints.length >= 2) {
      cubit.addPath(
        PathData(
          points: [currentPoints.first, currentPoints.last],
          color: state.selectedColor,
          strokeWidth: state.strokeWidth.sp,
        ),
      );
    }
  }
}
