import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class UnlockPdfService {
  Future<File> unlockPdf({
    required File pdfFile,
    required String password,
  }) async {
    final bytes = await pdfFile.readAsBytes();

    final PdfDocument document = PdfDocument(
      inputBytes: bytes,
      password: password,
    );

    document.security.userPassword = '';
    document.security.ownerPassword = '';

    final List<int> outputBytes = await document.save();

    document.dispose();

    final directory = await getApplicationDocumentsDirectory();

    final outputFile = File(
      '${directory.path}/unlocked_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await outputFile.writeAsBytes(outputBytes);

    return outputFile;
  }
}
