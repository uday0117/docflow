import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/df_widgets.dart';
import '../controller/compress_pdf_controller.dart';

class CompressPdfView extends StatelessWidget {
  CompressPdfView({super.key});

  final controller = Get.put(CompressPdfController());
  static const _color = AppColors.compressPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Compress PDF'), leading: const BackButton()),
      bottomNavigationBar: const BannerAdWidget(),
      body: Obx(() {
        final file = controller.selectedFile.value;
        final compressed = controller.compressedFile.value;
        final isCompressing = controller.isCompressing.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfToolHeader(
                title: 'Compress PDF',
                subtitle: 'Reduce file size for easy sharing',
                icon: Icons.compress_rounded,
                color: _color,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (isCompressing)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfLoadingCard(
                    message: 'Compressing PDF…',
                    color: _color,
                  ),
                ),
              )
            else if (compressed != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _SavingsCard(controller: controller),
                      const SizedBox(height: 12),
                      DfResultCard(
                        message: 'PDF Compressed!',
                        detail: '${controller.formattedOriginalSize} → ${controller.formattedCompressedSize}',
                        onOpen: controller.openFile,
                        onShare: controller.shareFile,
                        color: _color,
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: file == null
                      ? DfFilePickerCard(
                          onTap: controller.pickPdf,
                          label: 'Select a PDF',
                          hint: 'Choose the PDF\nyou want to compress',
                          icon: Icons.picture_as_pdf_rounded,
                          color: _color,
                        )
                      : DfSelectedFileCard(
                          fileName: file.path.split('/').last,
                          subtitle: 'Original: ${controller.formattedOriginalSize}',
                          color: _color,
                          onRemove: () => controller.selectedFile.value = null,
                        ),
                ),
              ),
              if (file != null) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _QualityCard(controller: controller),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: ElevatedButton.icon(
                      onPressed: isCompressing ? null : controller.compressPdf,
                      icon: const Icon(Icons.compress_rounded),
                      label: const Text('Compress PDF'),
                      style: ElevatedButton.styleFrom(backgroundColor: _color),
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

class _QualityCard extends StatelessWidget {
  final CompressPdfController controller;
  const _QualityCard({required this.controller});

  static const c = AppColors.compressPdf;

  String _label(double v) {
    if (v <= 20) return 'Maximum Compression';
    if (v <= 40) return 'High Compression';
    if (v <= 60) return 'Balanced';
    if (v <= 80) return 'Low Compression';
    return 'Minimal Compression';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Obx(() {
        final q = controller.quality.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: c, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Compression Level',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _label(q),
                    style: const TextStyle(
                      color: c,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Slider(
              value: q,
              min: 10,
              max: 90,
              divisions: 8,
              activeColor: c,
              onChanged: (v) => controller.quality.value = v,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Smaller file',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                ),
                Text(
                  'Better quality',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _SavingsCard extends StatelessWidget {
  final CompressPdfController controller;
  const _SavingsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final saved = controller.originalSize.value - controller.compressedSize.value;
    final pct = controller.originalSize.value > 0
        ? (saved / controller.originalSize.value * 100).toStringAsFixed(0)
        : '0';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.toolGradient(AppColors.compressPdf),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stat('$pct%', 'Space Saved'),
          Container(width: 1, height: 40, color: Colors.white30),
          _stat(controller.formattedOriginalSize, 'Original'),
          Container(width: 1, height: 40, color: Colors.white30),
          _stat(controller.formattedCompressedSize, 'Compressed'),
        ],
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
