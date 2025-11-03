import 'dart:io';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/shapes/logic/shape_factory.dart';
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

  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _startFocalPoint = Offset.zero;
  double _previousScale = 1.0;
  Offset _previousOffset = Offset.zero;

  String? _scalingImageId;
  double? _initialImageWidth;
  double? _initialImageHeight;

  // id نص نستخدمه أثناء التعديل (hit test)
  String? _editingTextId;

  final GlobalKey _canvasKey = GlobalKey();

  Offset _globalToCanvasLocal(Offset globalPoint) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Offset.zero;
    final local = box.globalToLocal(globalPoint);
    return (local - _offset) / _scale;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingCanvasCubit, DrawingCanvasState>(
      builder: (context, state) {
        final cubit = context.read<DrawingCanvasCubit>();

        return GestureDetector(
          onLongPressStart: (details) async {
            final pos = _globalToCanvasLocal(details.globalPosition);
            await cubit.addImage(fromCamera: false, position: pos);
          },

          onScaleStart: (details) {
            if (state.isHandTool) {
              _startFocalPoint = details.focalPoint;
              _previousOffset = _offset;
              _previousScale = _scale;
            } else {
              final pos = _globalToCanvasLocal(details.focalPoint);
              if (state.tool == "freehand" || state.tool == "line") {
                currentPoints = [pos];
              } else if (listOfCustomShapes.contains(state.tool)) {
                startShape = pos;
                currentPoints = [pos];
              } else if (state.tool == "eraser") {
                cubit.eraseAtPosition(pos);
              }
            }
          },

          onScaleUpdate: (details) {
            if (state.isHandTool) {
              setState(() {
                _scale = (_previousScale * details.scale).clamp(0.2, 8.0);
                _offset =
                    _previousOffset + (details.focalPoint - _startFocalPoint);
              });
              return;
            }

            final pos = _globalToCanvasLocal(details.focalPoint);
            setState(() {
              if (state.tool == "eraser") {
                cubit.eraseAtPosition(pos);
              } else if (state.tool == "freehand" || state.tool == "line") {
                currentPoints.add(pos);
              } else if (listOfCustomShapes.contains(state.tool)) {
                if (currentPoints.isEmpty) {
                  currentPoints = [startShape!, pos];
                } else {
                  currentPoints[currentPoints.length - 1] = pos;
                }
              }
            });
          },

          onScaleEnd: (details) {
            if (!state.isHandTool) {
              if (state.tool == "freehand") {
                _addHandPath(cubit, state);
              } else if (state.tool == "line") {
                _addLinePath(cubit, state);
              } else if (listOfCustomShapes.contains(state.tool) &&
                  startShape != null &&
                  currentPoints.isNotEmpty) {
                final endPos = currentPoints.last;
                final shapes = ShapeFactory.fromTool(
                  tool: state.tool,
                  start: startShape!,
                  end: endPos,
                  color: state.selectedColor,
                  strokeWidth: state.strokeWidth.sp,
                );
                for (var s in shapes) cubit.addShape(s);
                startShape = null;
              }
              currentPoints = [];
            }
          },

          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasWidth = constraints.maxWidth;
              final canvasHeight = constraints.maxHeight;

              return ClipRect(
                child: Container(
                  key: _canvasKey,
                  width: canvasWidth,
                  height: canvasHeight,
                  color: Colors.transparent,
                  child: Transform(
                    transform: Matrix4.identity()
                      ..translate(_offset.dx, _offset.dy)
                      ..scale(_scale),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // الرسم (CustomPainter)
                        CustomPaint(
                          size: Size(canvasWidth, canvasHeight),
                          painter: SketchPainter(
                            paths:
                                state.currentPaths +
                                ((state.tool == "freehand" ||
                                            state.tool == "line") &&
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
                            images: state.images,
                            originalSize: Size(canvasWidth, canvasHeight),
                            offset: _offset,
                            scale: _scale,
                            startShape: startShape,
                            currentShapePoints: currentPoints,
                            cubit: cubit,
                          ),
                        ),

                        // الصور (Widgets قابلة للسحب/التكبير)
                        ...state.images.map((img) {
                          final file = File(img.imagePath);
                          return Transform.translate(
                            offset: img.position,
                            child: GestureDetector(
                              onScaleStart: (details) {
                                if (state.tool != 'select') return;
                                _scalingImageId = img.id;
                                _initialImageWidth = img.width;
                                _initialImageHeight = img.height;
                              },
                              onScaleUpdate: (details) {
                                if (state.tool != 'select') return;
                                if (_scalingImageId != img.id) return;

                                if ((details.scale - 1.0).abs() < 1e-6) {
                                  // move image using focalPointDelta -> reliable even with overlays
                                  final deltaCanvas = Offset(
                                    details.focalPointDelta.dx / _scale,
                                    details.focalPointDelta.dy / _scale,
                                  );
                                  final newPos = img.position + deltaCanvas;
                                  cubit.moveImage(img.id, newPos);
                                } else {
                                  final newWidth =
                                      (_initialImageWidth ?? img.width) *
                                      details.scale;
                                  final newHeight =
                                      (_initialImageHeight ?? img.height) *
                                      details.scale;
                                  cubit.resizeImage(
                                    img.id,
                                    newWidth.clamp(20.0, 5000.0),
                                    newHeight.clamp(20.0, 5000.0),
                                  );
                                }
                              },
                              onScaleEnd: (_) {
                                _scalingImageId = null;
                                _initialImageWidth = null;
                                _initialImageHeight = null;
                              },
                              child: file.existsSync()
                                  ? Image.file(
                                      file,
                                      width: img.width,
                                      height: img.height,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: img.width,
                                      height: img.height,
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                            ),
                          );
                        }).toList(),

                        // ====== Double-tap detector لإضافة نص على منطقة فارغة ======
                        // REMOVED: Listener(onPointerDown: ...) -> لأنه كان يمتص الأحداث ويمنع وصول onScale للنصوص
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onDoubleTapDown: (details) async {
                              if (state.tool != 'text') return;

                              final pos = _globalToCanvasLocal(
                                details.globalPosition,
                              );

                              // تأكد ما بنعملش add فوق صورة أو نص موجود
                              bool hitExisting = false;

                              for (final img in state.images.reversed) {
                                final rect = Rect.fromLTWH(
                                  img.position.dx,
                                  img.position.dy,
                                  img.width,
                                  img.height,
                                );
                                if (rect.contains(pos)) {
                                  hitExisting = true;
                                  break;
                                }
                              }

                              if (!hitExisting) {
                                for (final t in state.textData.reversed) {
                                  final estimatedWidth =
                                      (t.text.length * (t.fontSize / 2.0));
                                  final textRect = Rect.fromLTWH(
                                    t.position.dx,
                                    t.position.dy,
                                    estimatedWidth,
                                    t.fontSize,
                                  );
                                  if (textRect.contains(pos)) {
                                    hitExisting = true;
                                    break;
                                  }
                                }
                              }

                              if (hitExisting) return;

                              final result = await showAddTextDialog(context);
                              if (result != null) {
                                final fontSize = (result["fontSize"] != null
                                    ? (result["fontSize"] as num).toDouble().sp
                                    : 18.sp);

                                cubit.addText(
                                  result["text"],
                                  position: pos,
                                  color: state.selectedColor,
                                  fontSize: fontSize,
                                  hasBackground:
                                      result["hasBackground"] ?? false,
                                  backgroundColor: result["backgroundColor"],
                                );
                              }
                            },
                            child: const SizedBox.expand(),
                          ),
                        ),

                        // النصوص (كل نص GestureDetector يتعامل مع onScale للحركة مثل الصور)
                        ...state.textData.map((t) {
                          return Transform.translate(
                            offset: t.position,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,

                              // MODIFIED: use onScale* so the gesture receives events reliably
                              onScaleStart: (d) {
                                debugPrint("text onScaleStart ${t.id}");
                                if (state.tool != 'select') return;
                                _editingTextId = t.id;
                              },

                              onScaleUpdate: (d) {
                                debugPrint(
                                  "text onScaleUpdate ${t.id} delta=${d.focalPointDelta}",
                                );

                                if (state.tool != 'select') return;
                                if (_editingTextId != t.id) return;

                                final deltaCanvas = Offset(
                                  d.focalPointDelta.dx / _scale,
                                  d.focalPointDelta.dy / _scale,
                                );

                                cubit.moveText(t.id, t.position + deltaCanvas);
                              },

                              onScaleEnd: (_) {
                                _editingTextId = null;
                              },

                              onDoubleTap: () async {
                                if (!state.isHandTool) return;

                                final result = await showAddTextDialog(
                                  context,
                                  initialText: t.text,
                                  initialFontSize: t.fontSize,
                                  initialHasBackground: t.hasBackground,
                                  initialBackgroundColor: t.backgroundColor,
                                  isEditing: true,
                                );

                                if (result != null) {
                                  final newFontSize =
                                      (result["fontSize"] != null
                                      ? (result["fontSize"] as num)
                                            .toDouble()
                                            .sp
                                      : t.fontSize);

                                  cubit.updateText(
                                    t.id,
                                    result["text"],
                                    newPosition: t.position,
                                    newFontSize: newFontSize,
                                    hasBackground: result["hasBackground"],
                                    backgroundColor: result["backgroundColor"],
                                  );
                                }
                              },

                              child: Container(
                                padding: EdgeInsets.all(8),
                                constraints: BoxConstraints(
                                  minWidth: 40,
                                  minHeight: 30,
                                ),
                                decoration: t.hasBackground
                                    ? BoxDecoration(
                                        color:
                                            t.backgroundColor ?? Colors.white,
                                        borderRadius: BorderRadius.circular(4),
                                      )
                                    : null,
                                child: Text(
                                  t.text,
                                  style: CustomTextStyles.cairoRegular18
                                      .copyWith(
                                        color: t.color,
                                        fontSize: t.fontSize,
                                      ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              );
            },
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

var listOfCustomShapes = [
  "rect",
  "circle",
  "door",
  "window",
  "custom1",
  "custom2",
  "custom3",
  "custom4",
  "custom5",
  "custom6",
  "custom7",
  "custom8",
  "custom9",
  "custom10",
  "custom11",
  "custom12",
];
