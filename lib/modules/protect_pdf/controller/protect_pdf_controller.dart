import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/services/ad_service.dart';
import '../service/protect_pdf_service.dart';

class ProtectPdfController extends GetxController {
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxBool isProcessing = false.obs;
  Rx<File?> protectedFile = Rx<File?>(null);

  final ProtectPdfService _service = ProtectPdfService();

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;
    selectedFile.value = File(result.files.single.path!);
    protectedFile.value = null;
  }

  Future<void> protectPdf(String password) async {
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Please select a PDF');
      return;
    }

    if (password.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter a password');
      return;
    }

    try {
      isProcessing.value = true;

      final file = await _service.protectPdf(
        selectedFile.value!,
        password.trim(),
      );

      protectedFile.value = file;

      AdService.to.showInterstitialAd(
        onDismissed: () {
          Get.snackbar('Success', 'PDF protected successfully!');
          OpenFilex.open(file.path);
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }
}
