import 'dart:io';

import 'package:docflow/core/services/file_storage_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class ProtectPdfService {
  Future<File> protectPdf(File pdfFile, String password) async {
    final bytes = await pdfFile.readAsBytes();

    final document = PdfDocument(inputBytes: bytes);

    // Apply password protection
    document.security.userPassword = password;
    document.security.ownerPassword = password;

    print('Password Applied: ${document.security.userPassword}');

    final List<int> protectedBytes = await document.save();

    document.dispose();

    final directory = await FileStorageService.getDocFlowDirectory();

    final outputFile = File(
      '${directory.path}/protected_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );

    await outputFile.writeAsBytes(protectedBytes);
    return outputFile;
  }
}
