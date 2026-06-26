import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/df_widgets.dart';
import '../controller/merge_pdf_controller.dart';

class MergePdfView extends StatelessWidget {
  MergePdfView({super.key});

  final controller = MergePdfController.to;
  static const _color = AppColors.mergePdf;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Merge PDF'), leading: const BackButton()),
      bottomNavigationBar: const BannerAdWidget(),
      body: Obx(() {
        final files = controller.selectedFiles;
        final merged = controller.mergedFile.value;
        final isMerging = controller.isMerging.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfToolHeader(
                title: 'Merge PDF',
                subtitle: 'Combine multiple PDFs into one file',
                icon: Icons.merge_rounded,
                color: _color,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (isMerging)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfLoadingCard(message: 'Merging PDFs…', color: _color),
                ),
              )
            else if (merged != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfResultCard(
                    message: 'PDFs Merged Successfully!',
                    detail: merged.path.split('/').last,
                    onOpen: controller.openMerged,
                    onShare: controller.shareMerged,
                    onSave: controller.saveToDevice,
                    color: _color,
                  ),
                ),
              ),
            if (files.isEmpty && !isMerging && merged == null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: DfFilePickerCard(
                      onTap: controller.pickPdfFiles,
                      label: 'Select PDF Files',
                      hint: 'Choose 2 or more PDFs\nto merge together',
                      icon: Icons.picture_as_pdf_rounded,
                      color: _color,
                    ),
                  ),
                ),
              )
            else if (files.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DfSectionLabel('SELECTED FILES (${files.length})'),
                      TextButton.icon(
                        onPressed: controller.pickPdfFiles,
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
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: DfSelectedFileCard(
                        fileName: files[i].path.split('/').last,
                        subtitle: _fileSize(files[i]),
                        color: _color,
                        onRemove: () => controller.removeFile(i),
                      ),
                    ),
                    childCount: files.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: ElevatedButton.icon(
                    onPressed: files.length < 2 || isMerging
                        ? null
                        : controller.mergePdfs,
                    icon: const Icon(Icons.merge_rounded),
                    label: const Text('Merge All PDFs'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _color),
                  ),
                ),
              ),
              if (files.length < 2)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Select at least 2 PDFs to merge',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45)),
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

  String _fileSize(File f) {
    try {
      final bytes = f.lengthSync();
      if (bytes < 1024) return '${bytes}B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } catch (_) {
      return '';
    }
  }
}
