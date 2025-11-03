import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/models/project_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_state.dart';
import 'package:alrahma/features/paint/cubit/drawings_nav_cubit.dart';
import 'package:alrahma/features/paint/logic/sketch_painter.dart';
import 'package:alrahma/features/paint/logic/snackbar_helper.dart';
import 'package:alrahma/features/paint/repository/drawing_repository.dart';
import 'package:alrahma/features/paint/screens/drawing_canvas_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ------------------ دوال التصدير ------------------
Future<Uint8List?> _capturePng(GlobalKey repaintKey) async {
  try {
    RenderRepaintBoundary boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  } catch (e) {
    print("❌ Error: $e");
    return null;
  }
}

Future<void> _exportToImage(GlobalKey repaintKey) async {
  final pngBytes = await _capturePng(repaintKey);
  if (pngBytes == null) return;

  try {
    await Gal.putImageBytes(pngBytes, album: "Alrahma UBVC");
    print("✅ Saved to Gallery");
  } catch (e) {
    print("❌ Error saving image: $e");
  }
}

Future<void> _exportToPdf(GlobalKey repaintKey, String filename) async {
  final pngBytes = await _capturePng(repaintKey);
  if (pngBytes == null) return;

  final pdf = pw.Document();
  final image = pw.MemoryImage(pngBytes);

  pdf.addPage(
    pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))),
  );

  await Printing.sharePdf(bytes: await pdf.save(), filename: filename);
}

// 🟦 حساب أقصى وأدنى نقاط لتحديد حجم الرسمة (آمن ضد nulls)
Rect calculateDrawingBounds(DrawingModel drawing) {
  double minX = double.infinity, minY = double.infinity;
  double maxX = double.negativeInfinity, maxY = double.negativeInfinity;

  // paths
  for (final p in drawing.paths) {
    for (final point in p.points) {
      // نقطة مفروض أنها non-null ضمن points لكن نحمي نفسنا
      if (point == null) continue;
      minX = point.dx < minX ? point.dx : minX;
      minY = point.dy < minY ? point.dy : minY;
      maxX = point.dx > maxX ? point.dx : maxX;
      maxY = point.dy > maxY ? point.dy : maxY;
    }
  }

  // shapes (تحقّق من start/end)
  for (final s in drawing.shapes) {
    final start = s.start;
    final end = s.end;
    if (start != null) {
      minX = start.dx < minX ? start.dx : minX;
      minY = start.dy < minY ? start.dy : minY;
      maxX = start.dx > maxX ? start.dx : maxX;
      maxY = start.dy > maxY ? start.dy : maxY;
    }
    if (end != null) {
      minX = end.dx < minX ? end.dx : minX;
      minY = end.dy < minY ? end.dy : minY;
      maxX = end.dx > maxX ? end.dx : maxX;
      maxY = end.dy > maxY ? end.dy : maxY;
    }
  }

  // texts (نقدّر العرض بناء على طول النص و fontSize)
  for (final t in drawing.texts) {
    minX = t.position.dx < minX ? t.position.dx : minX;
    minY = t.position.dy < minY ? t.position.dy : minY;
    final estimatedWidth = (t.text?.length ?? 0) * (t.fontSize / 1.5);
    maxX = (t.position.dx + estimatedWidth) > maxX
        ? (t.position.dx + estimatedWidth)
        : maxX;
    maxY = (t.position.dy + (t.fontSize ?? 0)) > maxY
        ? (t.position.dy + (t.fontSize ?? 0))
        : maxY;
  }

  // images
  for (final i in drawing.images) {
    minX = i.position.dx < minX ? i.position.dx : minX;
    minY = i.position.dy < minY ? i.position.dy : minY;
    maxX = (i.position.dx + (i.width ?? 0)) > maxX
        ? (i.position.dx + (i.width ?? 0))
        : maxX;
    maxY = (i.position.dy + (i.height ?? 0)) > maxY
        ? (i.position.dy + (i.height ?? 0))
        : maxY;
  }

  // لو مفيش عناصر نرجع قيمة افتراضية
  if (minX == double.infinity ||
      minY == double.infinity ||
      maxX == double.negativeInfinity ||
      maxY == double.negativeInfinity) {
    return const Rect.fromLTWH(0, 0, 1000, 1000);
  }

  return Rect.fromLTRB(minX, minY, maxX, maxY);
}

// ------------------ الصفحة ------------------
class DrawingPreviewPage extends StatelessWidget {
  final String drawingId;
  final List<ProjectModel> projects;
  final GlobalKey _previewKey = GlobalKey(); // 👈 مفتاح للـ RepaintBoundary

  DrawingPreviewPage({
    super.key,
    required this.drawingId,
    required this.projects,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DrawingsCubit, DrawingsState>(
      builder: (context, state) {
        final drawing = state.drawings.firstWhere(
          (d) => d.id == drawingId,
          orElse: () => throw Exception("Drawing not found"),
        );

        // ✅ استدعاء cubit الخاص بالكانفاس
        final drawingCanvasCubit = context.read<DrawingCanvasCubit>();

        // ✅ دايمًا حمل الصور الخاصة بالرسم عند الدخول للمعاينة
        drawingCanvasCubit.loadImagesForDrawing(drawing);

        // ✅ ربط الـ drawing.projectId بالـ project الصح
        final project = projects.firstWhere(
          (p) => p.id == drawing.projectId,
          orElse: () => throw Exception("Project not found for this drawing"),
        );

        final paths = drawing.paths;
        final shapes = drawing.shapes;
        final texts = drawing.texts;

        // احسب الـ bounds بعد الحصول على الرسم
        final bounds = calculateDrawingBounds(drawing);

        // نضيف padding احتياطي (يشمل سمك الخط + هامش عرض)
        const double padding = 20.0;
        final rawDrawingWidth = bounds.width + padding * 2;
        final rawDrawingHeight = bounds.height + padding * 2;

        // حد أقصى/دنيا لحجم الصندوق (زي اللي كنت محدده سابقًا)
        const double minPreview = 400.0;
        const double maxPreview = 1200.0;

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: Text(
                "معاينة الرسمة",
                style: CustomTextStyles.cairoBold20.copyWith(
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  tooltip: "تعديل الرسمة",
                  onPressed: () async {
                    final updatedDrawing = await Navigator.push<DrawingModel>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MultiBlocProvider(
                          providers: [
                            BlocProvider.value(
                              value: context.read<DrawingCanvasCubit>(),
                            ),
                            BlocProvider.value(
                              value: context.read<DrawingsCubit>(),
                            ),
                          ],
                          child: DrawingCanvasPage(
                            projects: projects,
                            existingDrawing: drawing,
                            onSave: (drawing) {
                              Navigator.pop(context, drawing);
                            },
                            repository: context.read<DrawingRepository>(),
                          ),
                        ),
                      ),
                    );

                    if (updatedDrawing != null) {
                      context.read<DrawingsCubit>().updateDrawing(
                        updatedDrawing,
                      );

                      SnackbarHelper.show(
                        context,
                        message: "تم تحديث الرسمة بنجاح",
                        backgroundColor: AppColors.primaryBlue,
                      );
                    }
                  },
                ),
              ],
            ),
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, Color(0xff1976d2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Expanded(
                    child: Center(
                      child: InteractiveViewer(
                        panEnabled: true,
                        scaleEnabled: true,
                        minScale: 1.0,
                        maxScale: 5.0,
                        child: RepaintBoundary(
                          key: _previewKey,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            child: Card(
                              key: ValueKey(drawing.id),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              elevation: 12,
                              shadowColor: AppColors.primaryBlue.withOpacity(
                                0.3,
                              ),
                              // نستخدم LayoutBuilder عشان نحسب المساحة المتاحة ونطبق scale مناسب
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  // المساحة المتاحة داخل الـ InteractiveViewer/Center
                                  final availableW =
                                      constraints.maxWidth.isFinite
                                      ? constraints.maxWidth
                                      : maxPreview;
                                  final availableH =
                                      constraints.maxHeight.isFinite
                                      ? constraints.maxHeight
                                      : maxPreview;

                                  // نحدد حجم الـ raw (قبل الـ scale) ثم نقيّده بين min/max
                                  final drawingWidth = rawDrawingWidth.clamp(
                                    minPreview,
                                    maxPreview,
                                  );
                                  final drawingHeight = rawDrawingHeight.clamp(
                                    minPreview,
                                    maxPreview,
                                  );

                                  // احسب scale بحيث الرسم يظهر كامـل داخل المساحة المتاحة
                                  double scale = 1.0;
                                  if (drawingWidth > 0 && drawingHeight > 0) {
                                    final scaleX = availableW / drawingWidth;
                                    final scaleY = availableH / drawingHeight;
                                    scale = scaleX < scaleY ? scaleX : scaleY;
                                    // لو عايز تمنع التكبير فوق 1.0 افعل السطر التالي:
                                    // scale = scale.clamp(0.0, 1.0);
                                  }

                                  // الناتج النهائي لصندوق العرض بعد تطبيق الـ scale
                                  final containerW = drawingWidth * scale;
                                  final containerH = drawingHeight * scale;

                                  return Container(
                                    width: containerW,
                                    height: containerH,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                    child: ClipRect(
                                      child: Transform.scale(
                                        scale: scale,
                                        alignment: Alignment.topLeft,
                                        child: Transform.translate(
                                          // نحرك الرسم ليبتدي من اليسار العلوى مع البادينج
                                          offset: Offset(
                                            -bounds.left + padding,
                                            -bounds.top + padding,
                                          ),
                                          child: SizedBox(
                                            width: drawingWidth,
                                            height: drawingHeight,
                                            child:
                                                BlocBuilder<
                                                  DrawingCanvasCubit,
                                                  DrawingCanvasState
                                                >(
                                                  builder: (context, canvasState) {
                                                    return Stack(
                                                      children: [
                                                        CustomPaint(
                                                          painter: SketchPainter(
                                                            paths: paths,
                                                            shapes: shapes,
                                                            texts: texts,
                                                            images:
                                                                drawing.images,
                                                            originalSize: Size(
                                                              drawingWidth,
                                                              drawingHeight,
                                                            ),
                                                            scale: 1.0,
                                                            cubit:
                                                                drawingCanvasCubit,
                                                          ),
                                                          child:
                                                              const SizedBox.expand(),
                                                        ),
                                                        ...drawing.images.map((
                                                          img,
                                                        ) {
                                                          final file = File(
                                                            img.imagePath,
                                                          );
                                                          if (!file
                                                              .existsSync()) {
                                                            return Positioned(
                                                              left: img
                                                                  .position
                                                                  .dx,
                                                              top: img
                                                                  .position
                                                                  .dy,
                                                              width: img.width,
                                                              height:
                                                                  img.height,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                          return Positioned(
                                                            left:
                                                                img.position.dx,
                                                            top:
                                                                img.position.dy,
                                                            width: img.width,
                                                            height: img.height,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              child: Image.file(
                                                                file,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          );
                                                        }),
                                                        ...texts.map((t) {
                                                          return Positioned(
                                                            left: t.position.dx,
                                                            top: t.position.dy,
                                                            child: Text(
                                                              t.text,
                                                              style: CustomTextStyles
                                                                  .cairoRegular18
                                                                  .copyWith(
                                                                    color:
                                                                        t.color,
                                                                    fontSize: t
                                                                        .fontSize,
                                                                  ),
                                                            ),
                                                          );
                                                        }),
                                                      ],
                                                    );
                                                  },
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ⬇️ أزرار التصدير تحت
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            final now = DateTime.now();
                            final formattedDate =
                                "${now.year}-${now.month}-${now.day}";
                            final filename =
                                "${project.clientName ?? 'عميل'}_${project.type}_$formattedDate.pdf";

                            _exportToPdf(_previewKey, filename);
                          },
                          icon: const Icon(Icons.picture_as_pdf, size: 22),
                          label: const Text(
                            "تصدير PDF",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _exportToImage(_previewKey),
                          icon: const Icon(Icons.image, size: 22),
                          label: const Text(
                            "تحميل كصورة",
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
