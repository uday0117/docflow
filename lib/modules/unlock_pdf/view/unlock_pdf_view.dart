import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/unlock_pdf_controller.dart';

class UnlockPdfView extends StatelessWidget {
  UnlockPdfView({super.key});

  final UnlockPdfController controller = Get.put(UnlockPdfController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: controller.pickPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Select PDF'),
            ),

            const SizedBox(height: 20),

            Obx(() {
              if (controller.selectedFile.value == null) {
                return const Text('No PDF selected');
              }

              return Text(controller.selectedFile.value!.path.split('/').last);
            }),

            const SizedBox(height: 20),

            TextField(
              decoration: const InputDecoration(
                labelText: 'PDF Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              onChanged: (value) {
                controller.password.value = value;
              },
            ),

            const SizedBox(height: 30),

            Obx(
              () => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.unlockPdf,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : const Text('Unlock PDF'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
