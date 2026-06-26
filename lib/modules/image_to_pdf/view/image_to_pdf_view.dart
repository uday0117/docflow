import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/df_widgets.dart';
import '../controller/image_to_pdf_controller.dart';

class ImageToPdfView extends StatelessWidget {
  ImageToPdfView({super.key});

  final controller = Get.put(ImageToPdfController());

  static const _color = AppColors.imageToPdf;

  void _showPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image to PDF'),
        leading: const BackButton(),
        actions: [
          Obx(
            () => controller.selectedImages.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: controller.clearImages,
                    tooltip: 'Clear all',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      bottomNavigationBar: const BannerAdWidget(),
      body: Obx(() {
        final images = controller.selectedImages;
        final generated = controller.generatedPdf.value;
        final isLoading = controller.isGenerating.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfToolHeader(
                title: 'Image to PDF',
                subtitle: 'Turn photos into a PDF document',
                icon: Icons.image_rounded,
                color: _color,
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 24)),
            if (isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfLoadingCard(
                    message: 'Creating your PDF…',
                    color: _color,
                  ),
                ),
              )
            else if (generated != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfResultCard(
                    message: 'PDF Created Successfully!',
                    detail: generated.path.split('/').last,
                    onOpen: controller.openPdf,
                    onShare: controller.sharePdf,
                    color: _color,
                  ),
                ),
              ),
            if (images.isEmpty && !isLoading)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DfFilePickerCard(
                        onTap: () => _showPickerSheet(context),
                        label: 'Add Images',
                        hint: 'Pick from gallery, camera,\nor file manager',
                        icon: Icons.add_photo_alternate_rounded,
                        color: _color,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            else if (images.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DfSectionLabel('SELECTED (${images.length})'),
                      TextButton.icon(
                        onPressed: () => _showPickerSheet(context),
                        icon: const Icon(Icons.add_rounded, size: 16),
                        label: const Text('Add More'),
                        style: TextButton.styleFrom(
                          foregroundColor: _color,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => DfImageThumb(
                      file: images[i],
                      onRemove: () => images.removeAt(i),
                    ),
                    childCount: images.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: ElevatedButton.icon(
                    onPressed: isLoading ? null : controller.generatePdf,
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text('Generate PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                    ),
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      }),
    );
  }
}

class _PickerSheet extends StatelessWidget {
  final ImageToPdfController controller;
  const _PickerSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Add Images',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          const SizedBox(height: 16),
          _sheetOption(context, Icons.camera_alt_rounded, 'Camera',
              'Capture a new photo', AppColors.imageToPdf, () {
            Get.back();
            controller.pickFromCamera();
          }),
          const SizedBox(height: 10),
          _sheetOption(context, Icons.photo_library_rounded, 'Gallery',
              'Choose from your photos', Colors.purple, () {
            Get.back();
            controller.pickFromGallery();
          }),
          const SizedBox(height: 10),
          _sheetOption(context, Icons.folder_rounded, 'File Manager',
              'Browse image files', Colors.teal, () {
            Get.back();
            controller.pickFromFileManager();
          }),
        ],
      ),
    );
  }

  Widget _sheetOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
