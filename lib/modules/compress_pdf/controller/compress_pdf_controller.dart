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
import '../service/compress_pdf_service.dart';

class CompressPdfController extends GetxController {
  static CompressPdfController get to =>
      Get.put(CompressPdfController(), permanent: true);

  final CompressPdfService _service = CompressPdfService();

  Rx<File?> selectedFile = Rx<File?>(null);
  Rx<File?> compressedFile = Rx<File?>(null);
  RxBool isCompressing = false.obs;
  RxInt originalSize = 0.obs;
  RxInt compressedSize = 0.obs;
  RxDouble quality = 60.0.obs;

  Future<void> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.paths.isEmpty) return;

    final file = File(result.paths.first!);
    selectedFile.value = file;
    compressedFile.value = null;

    final stat = await file.stat();
    originalSize.value = stat.size;
  }

  Future<void> compressPdf() async {
    if (selectedFile.value == null) {
      Get.snackbar('Error', 'Please select a PDF file first');
      return;
    }

    try {
      isCompressing.value = true;
      compressedFile.value = null;

      final output = await _service.compressPdf(
        selectedFile.value!,
        imageQuality: quality.value.toInt(),
      );

      compressedFile.value = output;
      final stat = await output.stat();
      compressedSize.value = stat.size;

      RecentFilesService.to.addFile(
        path: output.path,
        tool: 'compress_pdf',
        toolLabel: 'Compress PDF',
      );

      AnalyticsService.to.logToolUsed('compress_pdf');
      ReviewService.to.onToolCompleted();

      AdService.to.showInterstitialAd(
        onDismissed: () {
          final saved = originalSize.value - compressedSize.value;
          final pct = (saved / originalSize.value * 100).toStringAsFixed(1);
          Get.snackbar(
            'Compressed!',
            'Saved $pct% (${_formatBytes(saved)})',
            duration: const Duration(seconds: 4),
          );
        },
      );
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isCompressing.value = false;
    }
  }

  Future<void> openFile() async {
    if (compressedFile.value == null) return;
    await OpenFilex.open(compressedFile.value!.path);
  }

  Future<void> shareFile() async {
    if (compressedFile.value == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(compressedFile.value!.path)],
        text: 'Compressed PDF from DocFlow',
      ),
    );
  }

  Future<File?> saveToDevice() async {
    if (compressedFile.value == null) return null;
    final saved = await FileStorageService.saveToDownloads(compressedFile.value!);
    RecentFilesService.to.addFile(
      path: saved.path,
      tool: 'compress_pdf',
      toolLabel: 'Compress PDF',
    );
    return saved;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedOriginalSize => _formatBytes(originalSize.value);
  String get formattedCompressedSize => _formatBytes(compressedSize.value);
}
