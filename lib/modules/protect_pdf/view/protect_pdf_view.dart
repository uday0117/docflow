import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/protect_pdf_controller.dart';

class ProtectPdfView extends StatelessWidget {
  ProtectPdfView({super.key});

  final controller = Get.put(ProtectPdfController());

  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protect PDF')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: controller.pickPdf,
              child: const Text('Select PDF'),
            ),

            const SizedBox(height: 20),

            Obx(() {
              final file = controller.selectedFile.value;

              if (file == null) {
                return const Text('No PDF Selected');
              }

              return Text(file.path.split('/').last);
            }),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            Obx(
              () => ElevatedButton(
                onPressed: controller.isProcessing.value
                    ? null
                    : () {
                        controller.protectPdf(passwordController.text);
                      },
                child: Text(
                  controller.isProcessing.value
                      ? 'Processing...'
                      : 'Protect PDF',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
