import 'dart:io';

import 'package:docflow/modules/merge_pdf/service/merge_pdf_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

class MergePdfController extends GetxController {
  final RxList<File> selectedFiles = <File>[].obs;
  final RxBool isMerging = false.obs;

  final MergePdfService _service = MergePdfService();

  Future<void> pickPdfFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (result == null) return;

    selectedFiles.assignAll(
      result.paths
          .where((path) => path != null)
          .map((path) => File(path!))
          .toList(),
    );
  }

  Future<void> mergePdfs() async {
    if (selectedFiles.length < 2) {
      Get.snackbar('Error', 'Please select at least 2 PDF files');
      return;
    }

    try {
      isMerging.value = true;

      final mergedFile = await _service.mergePdfs(selectedFiles.toList());

      Get.snackbar('Success', 'PDF merged successfully');

      print('Merged File: ${mergedFile.path}');
    } catch (e) {
      print('Merge Error: $e');

      Get.snackbar('Error', e.toString());
    } finally {
      isMerging.value = false;
    }
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }
}
