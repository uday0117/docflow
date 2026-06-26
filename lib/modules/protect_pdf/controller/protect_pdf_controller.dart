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
import '../service/protect_pdf_service.dart';

class ProtectPdfController extends GetxController {
  static ProtectPdfController get to =>
      Get.put(ProtectPdfController(), permanent: true);

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

      RecentFilesService.to.addFile(
        path: file.path,
        tool: 'protect_pdf',
        toolLabel: 'Protect PDF',
      );

      AnalyticsService.to.logToolUsed('protect_pdf');
      ReviewService.to.onToolCompleted();

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

  Future<void> openFile() async {
    if (protectedFile.value == null) return;
    await OpenFilex.open(protectedFile.value!.path);
  }

  Future<void> shareFile() async {
    if (protectedFile.value == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(protectedFile.value!.path)],
        text: 'Password-protected PDF from DocFlow',
      ),
    );
  }

  Future<File?> saveToDevice() async {
    if (protectedFile.value == null) return null;
    final saved = await FileStorageService.saveToDownloads(protectedFile.value!);
    RecentFilesService.to.addFile(
      path: saved.path,
      tool: 'protect_pdf',
      toolLabel: 'Protect PDF',
    );
    return saved;
  }
}
