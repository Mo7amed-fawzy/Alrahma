import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> exportToPdf(Uint8List imageBytes) async {
  final pdf = pw.Document();

  final image = pw.MemoryImage(imageBytes);

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Center(child: pw.Image(image));
      },
    ),
  );

  await Printing.sharePdf(bytes: await pdf.save(), filename: "drawing.pdf");
}
