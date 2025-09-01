// lib/features/paint/utils/drawing_utils.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:alrahma/core/models/drawing_model.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_cubit.dart';
import 'package:alrahma/features/paint/cubit/drawing_canvas_state.dart';

/// تحويل إحداثيات الشاشة إلى إحداثيات محلية للكانفس مع التكبير والتحريك
Offset toLocalInZoom(
  BuildContext context,
  Offset global,
  Offset offset,
  double scale,
) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  return box.globalToLocal(global) / scale - offset / scale;
}

Offset toTextLocalPosition(
  BuildContext context,
  Offset global,
  Offset offset,
  double scale,
  String text, {
  double fontSize = 16,
}) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  final local = (box.globalToLocal(global) - offset) / scale;

  // نقيس حجم النص باستخدام TextPainter
  final textPainter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(fontSize: fontSize.sp),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  final textSize = textPainter.size;

  // نرجع مكان متوسّط حوالين الضغط
  return Offset(local.dx - textSize.width / 2, local.dy - textSize.height / 2);
}

/// رسم خط حر عند انتهاء الرسم
void handHandle(
  DrawingCanvasCubit cubit,
  DrawingCanvasState state,
  List<Offset> points,
) {
  if (points.isNotEmpty) {
    cubit.addPath(
      PathData(
        points: points,
        color: state.selectedColor,
        strokeWidth: state.strokeWidth.sp,
      ),
    );
  }
}

/// رسم خط مستقيم عند انتهاء الرسم
void lineHandle(
  DrawingCanvasCubit cubit,
  DrawingCanvasState state,
  List<Offset> points,
) {
  if (points.length >= 2) {
    cubit.addPath(
      PathData(
        points: [points.first, points.last],
        color: state.selectedColor,
        strokeWidth: state.strokeWidth,
      ),
    );
  }
}
