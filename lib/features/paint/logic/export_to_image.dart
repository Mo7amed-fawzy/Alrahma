import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

Future<void> exportToImage(GlobalKey repaintKey) async {
  try {
    RenderRepaintBoundary boundary =
        repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0); // دقة عالية
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/drawing.png');
    await file.writeAsBytes(pngBytes);

    print("✅ Saved to: ${file.path}");
  } catch (e) {
    print("❌ Error exporting image: $e");
  }
}
