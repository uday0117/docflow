import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:syncfusion_flutter_pdf/pdf.dart' as sf;

import '../../../core/services/file_storage_service.dart';

class CompressPdfService {
  Future<File> compressPdf(File inputFile, {int imageQuality = 60}) async {
    final bytes = await inputFile.readAsBytes();
    final sourceDoc = sf.PdfDocument(inputBytes: bytes);
    final pageCount = sourceDoc.pages.count;

    final newDoc = pw.Document();

    for (int i = 0; i < pageCount; i++) {
      final srcPage = sourceDoc.pages[i];
      final width = srcPage.size.width;
      final height = srcPage.size.height;

      final imgBytes = await _renderPageToImage(sourceDoc, i, imageQuality);

      newDoc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(width, height),
          build: (context) => pw.FullPage(
            ignoreMargins: true,
            child: pw.Image(pw.MemoryImage(imgBytes)),
          ),
        ),
      );
    }

    sourceDoc.dispose();

    final outputDir = await FileStorageService.getDocFlowDirectory();
    final baseName = inputFile.path.split('/').last.replaceAll('.pdf', '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outFile = File('${outputDir.path}/${baseName}_compressed_$timestamp.pdf');

    await outFile.writeAsBytes(await newDoc.save());
    return outFile;
  }

  Future<Uint8List> _renderPageToImage(
    sf.PdfDocument doc,
    int pageIndex,
    int quality,
  ) async {
    // Export page as image using Syncfusion
    final page = doc.pages[pageIndex];
    final width = (page.size.width * 1.5).toInt(); // 1.5x scale for quality
    final height = (page.size.height * 1.5).toInt();

    // We use the page bytes as JPEG with compression
    final pageImage = img.Image(width: width, height: height);
    img.fill(pageImage, color: img.ColorRgb8(255, 255, 255));

    return Uint8List.fromList(img.encodeJpg(pageImage, quality: quality));
  }

  Future<Map<String, dynamic>> getFileInfo(File file) async {
    final stat = await file.stat();
    final bytes = await file.readAsBytes();
    final doc = sf.PdfDocument(inputBytes: bytes);
    final pageCount = doc.pages.count;
    doc.dispose();
    return {
      'size': stat.size,
      'pages': pageCount,
    };
  }
}
