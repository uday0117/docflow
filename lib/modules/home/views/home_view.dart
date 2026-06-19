import 'package:docflow/modules/image_to_pdf/view/image_to_pdf_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'title': 'Image to PDF', 'icon': Icons.image},
      {'title': 'Merge PDF', 'icon': Icons.merge_type},
      {'title': 'Split PDF', 'icon': Icons.call_split},
      {'title': 'PDF to Image', 'icon': Icons.picture_as_pdf},
      {'title': 'Protect PDF', 'icon': Icons.lock},
      {'title': 'Unlock PDF', 'icon': Icons.lock_open},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('DocFlow'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: tools.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => ImageToPdfView());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(tools[index]['icon'] as IconData, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      tools[index]['title'] as String,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
