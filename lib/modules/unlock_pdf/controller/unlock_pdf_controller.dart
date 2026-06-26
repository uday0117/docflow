import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/ad_service.dart';
import '../service/unlock_pdf_service.dart';

class UnlockPdfController extends GetxController {
  final UnlockPdfService _service = UnlockPdfService();

  final selectedFile = Rx<File?>(null);
  final password = ''.obs;
  final isLoading = false.obs;
  Rx<File?> unlockedFile = Rx<File?>(null);

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      selectedFile.value = File(result.files.single.path!);
      unlockedFile.value = null;
    }
  }

  Future<void> unlockPdf() async {
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Please select a PDF');
      return;
    }

    if (password.value.isEmpty) {
      Get.snackbar('Error', 'Please enter password');
      return;
    }

    try {
      isLoading.value = true;

      final file = await _service.unlockPdf(
        pdfFile: selectedFile.value!,
        password: password.value,
      );

      unlockedFile.value = file;

      AdService.to.showInterstitialAd(
        onDismissed: () {
          Get.snackbar('Success', 'PDF unlocked successfully!');
          OpenFilex.open(file.path);
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
