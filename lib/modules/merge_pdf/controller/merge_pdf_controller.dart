import 'dart:io';

import 'package:docflow/modules/merge_pdf/service/merge_pdf_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/ad_service.dart';

class MergePdfController extends GetxController {
  final RxList<File> selectedFiles = <File>[].obs;
  final RxBool isMerging = false.obs;
  Rx<File?> mergedFile = Rx<File?>(null);

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

      final file = await _service.mergePdfs(selectedFiles.toList());
      mergedFile.value = file;

      AdService.to.showInterstitialAd(
        onDismissed: () {
          Get.snackbar('Success', 'PDFs merged successfully!');
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isMerging.value = false;
    }
  }

  Future<void> openMerged() async {
    if (mergedFile.value == null) return;
    await OpenFilex.open(mergedFile.value!.path);
  }

  Future<void> shareMerged() async {
    if (mergedFile.value == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(mergedFile.value!.path)],
        text: 'Merged PDF from DocFlow',
      ),
    );
  }

  void removeFile(int index) {
    selectedFiles.removeAt(index);
  }
}
