import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';

import '../service/protect_pdf_service.dart';

class ProtectPdfController extends GetxController {
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxBool isProcessing = false.obs;

  final ProtectPdfService _service = ProtectPdfService();

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    selectedFile.value = File(result.files.single.path!);
  }

  Future<void> protectPdf(String password) async {
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Please select a PDF');
      return;
    }

    if (password.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter password');
      return;
    }

    try {
      isProcessing.value = true;

      final protectedFile = await _service.protectPdf(
        selectedFile.value!,
        password.trim(),
      );

      Get.snackbar('Success', 'Protected PDF created successfully');

      print('Protected File: ${protectedFile.path}');

      await OpenFilex.open(protectedFile.path);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isProcessing.value = false;
    }
  }
}
