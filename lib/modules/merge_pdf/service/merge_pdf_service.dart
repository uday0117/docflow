import 'dart:io';

import 'package:docflow/core/services/file_storage_service.dart';
import 'package:pdf_combiner/models/merge_input.dart';
import 'package:pdf_combiner/pdf_combiner.dart';

class MergePdfService {
  Future<File> mergePdfs(List<File> pdfFiles) async {
    final directory = await FileStorageService.getDocFlowDirectory();

    final outputPath =
        '${directory.path}/merged_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final inputs = pdfFiles.map((file) => MergeInput.path(file.path)).toList();

    await PdfCombiner.mergeMultiplePDFs(inputs: inputs, outputPath: outputPath);

    return File(outputPath);
  }
}
