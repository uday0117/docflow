import 'dart:io';

import 'package:docflow/core/services/file_storage_service.dart';
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
    final directory = await FileStorageService.getDocFlowDirectory();

    final outputFile = File(
      '${directory.path}/protected_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await outputFile.writeAsBytes(outputBytes);

    return outputFile;
  }
}
