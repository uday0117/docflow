import 'package:docflow/modules/image_to_pdf/controller/image_to_pdf_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImageToPdfView extends StatelessWidget {
  ImageToPdfView({super.key});

  final controller = Get.put(ImageToPdfController());

  void showPickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                controller.pickFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                controller.pickFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('File Manager'),
              onTap: () {
                Get.back();
                controller.pickFromFileManager();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
        actions: [
          IconButton(
            onPressed: controller.clearImages,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedImages.isEmpty) {
          return FloatingActionButton(
            onPressed: showPickerOptions,
            child: const Icon(Icons.add),
          );
        }

        return FloatingActionButton.extended(
          onPressed: controller.isGenerating.value
              ? null
              : controller.generatePdf,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Generate PDF'),
        );
      }),
      body: Obx(() {
        if (controller.selectedImages.isEmpty) {
          return const Center(child: Text('Tap + to add images'));
        }

        return Column(
          children: [
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: controller.selectedImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      controller.selectedImages[index],
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),

            if (controller.generatedPdf.value != null)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    90, // extra space for FAB
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.openPdf,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Open'),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: controller.sharePdf,
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
