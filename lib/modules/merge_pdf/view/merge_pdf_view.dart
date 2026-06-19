import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/merge_pdf_controller.dart';

class MergePdfView extends StatelessWidget {
  MergePdfView({super.key});

  final MergePdfController controller = Get.put(MergePdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merge PDF'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.pickPdfFiles,
                icon: const Icon(Icons.upload_file),
                label: const Text('Select PDFs'),
              ),
            ),

            const SizedBox(height: 12),

            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isMerging.value
                      ? null
                      : controller.mergePdfs,
                  icon: controller.isMerging.value
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.merge_type),
                  label: Text(
                    controller.isMerging.value ? 'Merging...' : 'Merge PDFs',
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selected Files (${controller.selectedFiles.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: Obx(() {
                if (controller.selectedFiles.isEmpty) {
                  return const Center(
                    child: Text(
                      'No PDF files selected',
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: controller.selectedFiles.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final file = controller.selectedFiles[index];

                    return ListTile(
                      leading: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                      title: Text(
                        file.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        file.path,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          controller.removeFile(index);
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
