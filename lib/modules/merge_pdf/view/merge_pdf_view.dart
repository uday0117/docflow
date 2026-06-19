import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/merge_pdf_controller.dart';

class MergePdfView extends StatelessWidget {
  MergePdfView({super.key});

  final controller = Get.put(MergePdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merge PDF')),
      body: Column(
        children: [
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: controller.pickPdfFiles,
            child: const Text('Select PDFs'),
          ),
          Obx(
            () => ElevatedButton(
              onPressed: controller.isMerging.value
                  ? null
                  : controller.mergePdfs,
              child: Text(
                controller.isMerging.value ? 'Merging...' : 'Merge PDFs',
              ),
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Obx(
              () => ListView.builder(
                itemCount: controller.selectedFiles.length,
                itemBuilder: (context, index) {
                  final file = controller.selectedFiles[index];

                  return ListTile(
                    leading: const Icon(Icons.picture_as_pdf),
                    title: Text(file.path.split('/').last),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        controller.removeFile(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
