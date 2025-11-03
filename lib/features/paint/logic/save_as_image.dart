// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:file_saver/file_saver.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:alrahma/core/utils/app_colors.dart';
// import 'package:alrahma/core/utils/custom_text_styles.dart';
// import 'package:flutter/services.dart';

// class SaveImageUtil {
//   static const MethodChannel _channel = MethodChannel('save_image_util');

//   static Future<void> saveAsImage({
//     required GlobalKey paintKey,
//     required BuildContext context,
//   }) async {
//     try {
//       final boundary =
//           paintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
//       final image = await boundary.toImage(pixelRatio: 3.0);
//       final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       final pngBytes = byteData!.buffer.asUint8List();

//       final fileName = "drawing_${DateTime.now().millisecondsSinceEpoch}.png";

//       final savedFile = await FileSaver.instance.saveFile(
//         name: fileName,
//         bytes: pngBytes,
//         fileExtension: "png",
//         mimeType: MimeType.png,
//       );

//       if (savedFile != null && Platform.isAndroid) {
//         // MediaScanner لاظهار الصورة في المعرض
//         try {
//           await _channel.invokeMethod('scanFile', {'path': savedFile});
//         } catch (_) {}
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "✅ تم حفظ الصورة بنجاح",
//             style: CustomTextStyles.cairoRegular14.copyWith(
//               color: Colors.white,
//             ),
//           ),
//           backgroundColor: AppColors.accentOrange,
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             "❌ خطأ أثناء الحفظ: $e",
//             style: CustomTextStyles.cairoRegular14.copyWith(
//               color: Colors.white,
//             ),
//           ),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//     }
//   }
// }
