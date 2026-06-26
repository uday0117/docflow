import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/services/ad_service.dart';
import '../service/pdf_to_image_service.dart';

class PdfToImageController extends GetxController {
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
}
