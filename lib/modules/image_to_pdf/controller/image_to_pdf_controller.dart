import 'dart:io';

import 'package:docflow/modules/image_to_pdf/service/image_to_pdf_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class ImageToPdfController extends GetxController {
  final ImagePicker picker = ImagePicker();
  final ImageToPdfService imageToPdfService = ImageToPdfService();
  Rx<File?> generatedPdf = Rx<File?>(null);

  RxList<File> selectedImages = <File>[].obs;
  RxBool isGenerating = false.obs;

  Future<void> pickFromCamera() async {
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );

    if (image != null) {
      selectedImages.add(File(image.path));
    }
  }

  Future<void> pickFromGallery() async {
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 100);

    selectedImages.addAll(images.map((e) => File(e.path)));
  }

  Future<void> pickFromFileManager() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.image,
    );

    if (result != null) {
      selectedImages.addAll(
        result.paths.whereType<String>().map((path) => File(path)),
      );
    }
  }

  Future<void> generatePdf() async {
    if (selectedImages.isEmpty) {
      Get.snackbar('No Images', 'Please select images first');
      return;
    }

    try {
      isGenerating.value = true;

      final pdfFile = await imageToPdfService.createPdf(selectedImages);

      generatedPdf.value = pdfFile;
      Get.snackbar('Success', 'PDF Created Successfully');

      print(pdfFile.path);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> openPdf() async {
    if (generatedPdf.value == null) return;

    await OpenFilex.open(generatedPdf.value!.path);
  }

  Future<void> sharePdf() async {
    if (generatedPdf.value == null) return;

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(generatedPdf.value!.path)],
        text: 'PDF created with DocFlow',
      ),
    );
  }

  void clearImages() {
    selectedImages.clear();
  }
}
