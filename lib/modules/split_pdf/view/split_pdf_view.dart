import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/df_widgets.dart';
import '../controller/split_pdf_controller.dart';

class SplitPdfView extends StatelessWidget {
  SplitPdfView({super.key});

  final controller = Get.put(SplitPdfController());
  static const _color = AppColors.splitPdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Split PDF'), leading: const BackButton()),
      bottomNavigationBar: const BannerAdWidget(),
      body: Obx(() {
        final file = controller.selectedFile.value;
        final isSplitting = controller.isSplitting.value;
        final outputs = controller.outputFiles;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfToolHeader(
                title: 'Split PDF',
                subtitle: 'Extract individual pages or ranges',
                icon: Icons.call_split_rounded,
                color: _color,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (isSplitting)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfLoadingCard(message: 'Splitting PDF…', color: _color),
                ),
              )
            else if (file == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: DfFilePickerCard(
                      onTap: controller.pickPdf,
                      label: 'Select a PDF',
                      hint: 'Choose the PDF you want\nto split into pages',
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
                    fileName: file.path.split('/').last,
                    subtitle: '${controller.pageCount.value} pages',
                    color: _color,
                    onRemove: () {
                      controller.selectedFile.value = null;
                      controller.outputFiles.clear();
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SplitModeCard(controller: controller),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: ElevatedButton.icon(
                    onPressed: isSplitting ? null : controller.splitPdf,
                    icon: const Icon(Icons.call_split_rounded),
                    label: const Text('Split PDF'),
                    style: ElevatedButton.styleFrom(backgroundColor: _color),
                  ),
                ),
              ),
              if (outputs.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DfSectionLabel('OUTPUT FILES (${outputs.length})'),
                        TextButton.icon(
                          onPressed: controller.shareFiles,
                          icon: const Icon(Icons.share_rounded, size: 16),
                          label: const Text('Share All'),
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
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: DfSelectedFileCard(
                          fileName: outputs[i].path.split('/').last,
                          color: _color,
                          onRemove: null,
                        ),
                      ),
                      childCount: outputs.length,
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

class _SplitModeCard extends StatelessWidget {
  final SplitPdfController controller;
  const _SplitModeCard({required this.controller});

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
        final mode = controller.splitMode.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DfSectionLabel('SPLIT MODE'),
            Row(
              children: [
                _ModeChip(
                  label: 'All Pages',
                  selected: mode == 'all',
                  onTap: () => controller.splitMode.value = 'all',
                ),
                const SizedBox(width: 10),
                _ModeChip(
                  label: 'Page Range',
                  selected: mode == 'range',
                  onTap: () => controller.splitMode.value = 'range',
                ),
              ],
            ),
            if (mode == 'range') ...[
              const SizedBox(height: 16),
              const DfSectionLabel('FROM PAGE'),
              Slider(
                value: controller.startPage.value.toDouble(),
                min: 1,
                max: controller.pageCount.value.toDouble().clamp(1, double.infinity),
                divisions: (controller.pageCount.value - 1).clamp(1, 500),
                label: 'Page ${controller.startPage.value}',
                activeColor: AppColors.splitPdf,
                onChanged: (v) {
                  controller.startPage.value = v.toInt();
                  if (controller.endPage.value < v.toInt()) {
                    controller.endPage.value = v.toInt();
                  }
                },
              ),
              const DfSectionLabel('TO PAGE'),
              Slider(
                value: controller.endPage.value.toDouble(),
                min: 1,
                max: controller.pageCount.value.toDouble().clamp(1, double.infinity),
                divisions: (controller.pageCount.value - 1).clamp(1, 500),
                label: 'Page ${controller.endPage.value}',
                activeColor: AppColors.splitPdf,
                onChanged: (v) {
                  controller.endPage.value = v.toInt();
                  if (controller.startPage.value > v.toInt()) {
                    controller.startPage.value = v.toInt();
                  }
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.splitPdf.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Extracting pages ${controller.startPage.value}–${controller.endPage.value}',
                  style: const TextStyle(
                    color: AppColors.splitPdf,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.splitPdf
              : AppColors.splitPdf.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.splitPdf,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
