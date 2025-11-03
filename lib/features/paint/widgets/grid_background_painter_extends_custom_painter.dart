import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GridBackgroundPainter extends CustomPainter {
  final double gridSize;
  final Color lineColor;

  GridBackgroundPainter({
    this.gridSize = 20,
    this.lineColor = const ui.Color.fromARGB(255, 255, 255, 255),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1;

    // خطوط رأسية
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // خطوط أفقية
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
