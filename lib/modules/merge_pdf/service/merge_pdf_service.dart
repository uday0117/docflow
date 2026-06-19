import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf_combiner/models/merge_input.dart';
import 'package:pdf_combiner/pdf_combiner.dart';

class MergePdfService {
  // Future<File> mergePdfs(List<File> pdfFiles) async {
  //   final directory = await getApplicationDocumentsDirectory();

  //   final outputPath =
  //       '${directory.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';

  //   final inputs = pdfFiles.map((file) => MergeInput.path(file.path)).toList();

  //   await PdfCombiner.mergeMultiplePDFs(inputs: inputs, outputPath: outputPath);

  //    File(outputPath);
  //   print('Output Exists: ${await outputFile.exists()}');
  //   print('Output Size: ${await outputFile.length()}');
  // }

  Future<File> mergePdfs(List<File> pdfFiles) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final outputPath =
          '${directory.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final inputs = pdfFiles
          .map((file) => MergeInput.path(file.path))
          .toList();

      await PdfCombiner.mergeMultiplePDFs(
        inputs: inputs,
        outputPath: outputPath,
      );

      final outputFile = File(outputPath);

      print('Output Exists: ${await outputFile.exists()}');
      print('Output Size: ${await outputFile.length()}');

      return outputFile;
    } catch (e) {
      print('Merge Error: $e');
      rethrow;
    }
  }
}
