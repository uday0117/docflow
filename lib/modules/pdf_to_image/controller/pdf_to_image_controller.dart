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
import '../service/pdf_to_image_service.dart';

class PdfToImageController extends GetxController {
  static PdfToImageController get to =>
      Get.put(PdfToImageController(), permanent: true);

  final PdfToImageService _service = PdfToImageService();

  final Rx<File?> selectedPdf = Rx<File?>(null);
  final RxList<File> generatedImages = <File>[].obs;
  final RxBool isLoading = false.obs;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null && result.files.single.path != null) {
      selectedPdf.value = File(result.files.single.path!);
      generatedImages.clear();
    }
  }

  Future<void> convertPdf() async {
    if (selectedPdf.value == null) {
      Get.snackbar('Error', 'Please select a PDF');
      return;
    }

    try {
      isLoading.value = true;
      generatedImages.value = await _service.convertPdfToImages(
        selectedPdf.value!,
      );

      for (final img in generatedImages) {
        RecentFilesService.to.addFile(
          path: img.path,
          tool: 'pdf_to_image',
          toolLabel: 'PDF to Image',
        );
      }

      AnalyticsService.to.logToolUsed('pdf_to_image');
      ReviewService.to.onToolCompleted();

      AdService.to.showInterstitialAd(
        onDismissed: () {
          Get.snackbar('Success', '${generatedImages.length} images generated');
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> openImage(File file) async {
    await OpenFilex.open(file.path);
  }

  Future<void> shareImage(File file) async {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)]),
    );
  }

  Future<File?> saveToDevice(File file) async {
    final saved = await FileStorageService.saveToDownloads(file);
    RecentFilesService.to.addFile(
      path: saved.path,
      tool: 'pdf_to_image',
      toolLabel: 'PDF to Image',
    );
    return saved;
  }
}
