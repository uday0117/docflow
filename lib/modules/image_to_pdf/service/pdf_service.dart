import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfService {
  Future<File> createPdf(List<File> images) async {
    final pdf = pw.Document();

    for (final imageFile in images) {
      final imageBytes = await imageFile.readAsBytes();

      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (context) {
            return pw.Center(child: pw.Image(image));
          },
        ),
      );
    }

    Directory baseDir;

    if (Platform.isAndroid) {
      baseDir = (await getExternalStorageDirectory())!;
    } else {
      baseDir = await getApplicationDocumentsDirectory();
    }

    final docFlowDir = Directory('${baseDir.path}/DocFlow');

    if (!await docFlowDir.exists()) {
      await docFlowDir.create(recursive: true);
    }

    final file = File(
      '${docFlowDir.path}/docflow_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    return file;
  }
}
