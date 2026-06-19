import 'dart:io';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../core/services/file_storage_service.dart';

class ImageToPdfService {
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

    final directory = await FileStorageService.getDocFlowDirectory();

    final file = File(
      '${directory.path}/image_to_pdf_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await file.writeAsBytes(await pdf.save());

    print('Generated PDF: ${file.path}');

    return file;
  }
}
