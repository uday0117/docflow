import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/pdf_to_image_controller.dart';

class PdfToImageView extends StatelessWidget {
  PdfToImageView({super.key});

  final PdfToImageController controller = Get.put(PdfToImageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF to Image')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(
          () => Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.pickPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Select PDF'),
                ),
              ),

              const SizedBox(height: 16),

              if (controller.selectedPdf.value != null)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(
                      controller.selectedPdf.value!.path.split('/').last,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.convertPdf,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Convert PDF'),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: controller.generatedImages.isEmpty
                    ? const Center(child: Text('No Images Generated'))
                    : GridView.builder(
                        itemCount: controller.generatedImages.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemBuilder: (context, index) {
                          final File file = controller.generatedImages[index];

                          return Card(
                            child: Column(
                              children: [
                                Expanded(
                                  child: Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.open_in_new),
                                      onPressed: () {
                                        controller.openImage(file);
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        controller.shareImage(file);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
