import 'package:flutter/material.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:alrahma/features/paint/logic/sketch_painter.dart';

class DrawingPreviewPage extends StatefulWidget {
  final List<PathData> paths;
  final List<ShapeData> shapes;
  final List<TextData> texts;
  final Size originalSize;

  const DrawingPreviewPage({
    super.key,
    required this.paths,
    required this.shapes,
    required this.texts,
    required this.originalSize,
  });

  @override
  State<DrawingPreviewPage> createState() => _DrawingPreviewPageState();
}

class _DrawingPreviewPageState extends State<DrawingPreviewPage> {
  final GlobalKey _paintKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.95;
    final screenHeight = MediaQuery.of(context).size.height * 0.7;

    // حساب scale بحيث الرسم كله يظهر بدون قص
    double scale;
    if (widget.originalSize.width / widget.originalSize.height >
        screenWidth / screenHeight) {
      scale = screenWidth / widget.originalSize.width;
    } else {
      scale = screenHeight / widget.originalSize.height;
    }

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
          elevation: 4,
          shadowColor: Colors.orange.withOpacity(0.4),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            scaleEnabled: true,
            minScale: 1.0, // لا نصغر الرسم
            maxScale: 5.0, // يمكن تكبيره حتى 5 مرات
            child: RepaintBoundary(
              key: _paintKey,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
                shadowColor: Colors.orange.withOpacity(0.25),
                child: Container(
                  width: widget.originalSize.width,
                  height: widget.originalSize.height,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: CustomPaint(
                    painter: SketchPainter(
                      paths: widget.paths,
                      shapes: widget.shapes,
                      texts: widget.texts,
                      originalSize: widget.originalSize,
                      scale: 1.0, // نرسم بالحجم الطبيعي
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
