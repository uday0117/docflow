import 'dart:io';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../../../core/services/file_storage_service.dart';

class SplitPdfService {
  Future<List<File>> splitPdf(File inputFile, List<int> pageRanges) async {
    final bytes = await inputFile.readAsBytes();
    final sourceDoc = PdfDocument(inputBytes: bytes);
    final pageCount = sourceDoc.pages.count;

    final outputDir = await FileStorageService.getDocFlowDirectory();
    final baseName = inputFile.path.split('/').last.replaceAll('.pdf', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final List<File> outputFiles = [];

    for (int i = 0; i < pageCount; i++) {
      final newDoc = PdfDocument();
      final page = newDoc.pages.add();
      final srcPage = sourceDoc.pages[i];

      final graphics = page.graphics;
      final template = srcPage.createTemplate();
      graphics.drawPdfTemplate(
        template,
        const Offset(0, 0),
        Size(srcPage.size.width, srcPage.size.height),
      );

      final outFile = File('${outputDir.path}/${baseName}_page${i + 1}_$timestamp.pdf');
      await outFile.writeAsBytes(await newDoc.save());
      outputFiles.add(outFile);
      newDoc.dispose();
    }

    sourceDoc.dispose();
    return outputFiles;
  }

  Future<List<File>> splitPdfByRanges(
    File inputFile,
    List<Map<String, int>> ranges,
  ) async {
    final bytes = await inputFile.readAsBytes();
    final sourceDoc = PdfDocument(inputBytes: bytes);

    final outputDir = await FileStorageService.getDocFlowDirectory();
    final baseName = inputFile.path.split('/').last.replaceAll('.pdf', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final List<File> outputFiles = [];
    int partIndex = 1;

    for (final range in ranges) {
      final start = range['start']! - 1;
      final end = range['end']! - 1;

      if (start < 0 || end >= sourceDoc.pages.count || start > end) continue;

      final newDoc = PdfDocument();

      for (int i = start; i <= end; i++) {
        final page = newDoc.pages.add();
        final srcPage = sourceDoc.pages[i];
        final graphics = page.graphics;
        final template = srcPage.createTemplate();
        graphics.drawPdfTemplate(
          template,
          const Offset(0, 0),
          Size(srcPage.size.width, srcPage.size.height),
        );
      }

      final outFile = File(
        '${outputDir.path}/${baseName}_part${partIndex}_$timestamp.pdf',
      );
      await outFile.writeAsBytes(await newDoc.save());
      outputFiles.add(outFile);
      newDoc.dispose();
      partIndex++;
    }

    sourceDoc.dispose();
    return outputFiles;
  }

  Future<int> getPageCount(File pdfFile) async {
    final bytes = await pdfFile.readAsBytes();
    final doc = PdfDocument(inputBytes: bytes);
    final count = doc.pages.count;
    doc.dispose();
    return count;
  }
}
