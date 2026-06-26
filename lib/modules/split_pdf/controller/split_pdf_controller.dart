import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/ad_service.dart';
import '../../../core/services/analytics_service.dart';
import '../../../core/services/file_storage_service.dart';
import '../../../core/services/recent_files_service.dart';
import '../../../core/services/review_service.dart';
import '../service/split_pdf_service.dart';

class SplitPdfController extends GetxController {
  static SplitPdfController get to =>
      Get.put(SplitPdfController(), permanent: true);

  final SplitPdfService _service = SplitPdfService();

  Rx<File?> selectedFile = Rx<File?>(null);
  RxInt pageCount = 0.obs;
  RxBool isSplitting = false.obs;
  RxList<File> outputFiles = <File>[].obs;

  final RxString splitMode = 'all'.obs;
  final RxInt startPage = 1.obs;
  final RxInt endPage = 1.obs;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.paths.isEmpty) return;

    final file = File(result.paths.first!);
    selectedFile.value = file;
    outputFiles.clear();

    try {
      pageCount.value = await _service.getPageCount(file);
      endPage.value = pageCount.value;
    } catch (e) {
      Get.snackbar('Error', 'Could not read PDF: $e');
    }
  }

  Future<void> splitPdf() async {
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Please select a PDF file first');
      return;
    }

    try {
      isSplitting.value = true;
      outputFiles.clear();

      List<File> files;
      if (splitMode.value == 'all') {
        files = await _service.splitPdf(selectedFile.value!, []);
      } else {
        files = await _service.splitPdfByRanges(selectedFile.value!, [
          {'start': startPage.value, 'end': endPage.value},
        ]);
      }

      outputFiles.assignAll(files);

      for (final f in files) {
        RecentFilesService.to.addFile(
          path: f.path,
          tool: 'split_pdf',
          toolLabel: 'Split PDF',
        );
      }

      AnalyticsService.to.logToolUsed('split_pdf');
      ReviewService.to.onToolCompleted();

      AdService.to.showInterstitialAd(
        onDismissed: () {
          Get.snackbar(
            'Success',
            'Split into ${files.length} file(s)',
            duration: const Duration(seconds: 3),
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isSplitting.value = false;
    }
  }

  Future<void> openFile(File file) async {
    await OpenFilex.open(file.path);
  }

  Future<void> shareFiles() async {
    if (outputFiles.isEmpty) return;
    await SharePlus.instance.share(
      ShareParams(
        files: outputFiles.map((f) => XFile(f.path)).toList(),
        text: 'Split PDF pages from DocFlow',
      ),
    );
  }

  Future<File?> saveToDevice(File file) async {
    final saved = await FileStorageService.saveToDownloads(file);
    RecentFilesService.to.addFile(
      path: saved.path,
      tool: 'split_pdf',
      toolLabel: 'Split PDF',
    );
    return saved;
  }
}
