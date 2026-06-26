import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/df_widgets.dart';
import '../controller/pdf_to_image_controller.dart';

class PdfToImageView extends StatelessWidget {
  PdfToImageView({super.key});

  final controller = PdfToImageController.to;
  static const _color = AppColors.pdfToImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF to Image'), leading: const BackButton()),
      bottomNavigationBar: const BannerAdWidget(),
      body: Obx(() {
        final pdf = controller.selectedPdf.value;
        final images = controller.generatedImages;
        final isLoading = controller.isLoading.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfToolHeader(
                title: 'PDF to Image',
                subtitle: 'Export every PDF page as a PNG',
                icon: Icons.photo_library_rounded,
                color: _color,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfLoadingCard(
                    message: 'Converting PDF pages to images…',
                    color: _color,
                  ),
                ),
              )
            else if (pdf == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: DfFilePickerCard(
                      onTap: controller.pickPdf,
                      label: 'Select a PDF',
                      hint: 'Pick the PDF to\nconvert into images',
                      icon: Icons.picture_as_pdf_rounded,
                      color: _color,
                    ),
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: DfSelectedFileCard(
                    fileName: pdf.path.split('/').last,
                    color: _color,
                    onRemove: () {
                      controller.selectedPdf.value = null;
                      controller.generatedImages.clear();
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              if (images.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: controller.convertPdf,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Convert to Images'),
                      style: ElevatedButton.styleFrom(backgroundColor: _color),
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                    child: DfSectionLabel(
                        'EXPORTED IMAGES (${images.length})'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _ImageCard(
                        file: images[i],
                        index: i + 1,
                        onOpen: () => controller.openImage(images[i]),
                        onShare: () => controller.shareImage(images[i]),
                        onSave: () => controller.saveToDevice(images[i]),
                        color: _color,
                      ),
                      childCount: images.length,
                    ),
                  ),
                ),
              ],
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        );
      }),
    );
  }
}

class _ImageCard extends StatefulWidget {
  final dynamic file;
  final int index;
  final VoidCallback onOpen;
  final VoidCallback onShare;
  final Future<File?> Function()? onSave;
  final Color color;

  const _ImageCard({
    required this.file,
    required this.index,
    required this.onOpen,
    required this.onShare,
    this.onSave,
    required this.color,
  });

  @override
  State<_ImageCard> createState() => _ImageCardState();
}

class _ImageCardState extends State<_ImageCard> {
  bool _saving = false;
  bool _saved = false;

  Future<void> _handleSave() async {
    if (_saving || widget.onSave == null) return;
    setState(() => _saving = true);
    try {
      await widget.onSave!();
      if (mounted) setState(() { _saving = false; _saved = true; });
    } catch (_) {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = widget.color;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(widget.file, fit: BoxFit.cover),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Page ${widget.index}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                _ActionBtn(
                  icon: Icons.open_in_new_rounded,
                  color: color,
                  filled: false,
                  onTap: widget.onOpen,
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: Icons.share_rounded,
                  color: color,
                  filled: true,
                  onTap: widget.onShare,
                ),
                const SizedBox(width: 6),
                _ActionBtn(
                  icon: _saving
                      ? Icons.hourglass_top_rounded
                      : _saved
                          ? Icons.check_circle_rounded
                          : Icons.download_rounded,
                  color: _saved ? Colors.green : color,
                  filled: false,
                  onTap: _handleSave,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: filled ? color : color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon,
              color: filled ? Colors.white : color, size: 16),
        ),
      ),
    );
  }
}
