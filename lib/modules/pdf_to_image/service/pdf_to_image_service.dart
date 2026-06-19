import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';

class PdfToImageService {
  Future<List<File>> convertPdfToImages(File pdfFile) async {
    final PdfDocument document = await PdfDocument.openFile(pdfFile.path);

    final Directory directory = await getApplicationDocumentsDirectory();

    final List<File> generatedImages = [];

    for (int i = 1; i <= document.pagesCount; i++) {
      final PdfPage page = await document.getPage(i);

      final PdfPageImage? image = await page.render(
        width: page.width.toInt() * 2,
        height: page.height.toInt() * 2,
        format: PdfPageImageFormat.png,
      );

      if (image != null) {
        final File imageFile = File('${directory.path}/page_$i.png');

        await imageFile.writeAsBytes(image.bytes);

        generatedImages.add(imageFile);
      }

      await page.close();
    }

    await document.close();

    return generatedImages;
  }
}
