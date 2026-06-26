import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/pro_service.dart';
import '../../../core/services/recent_files_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/pro_upgrade_sheet.dart';
import '../../compress_pdf/view/compress_pdf_view.dart';
import '../../image_to_pdf/view/image_to_pdf_view.dart';
import '../../merge_pdf/view/merge_pdf_view.dart';
import '../../pdf_to_image/view/pdf_to_image_view.dart';
import '../../protect_pdf/view/protect_pdf_view.dart';
import '../../split_pdf/view/split_pdf_view.dart';
import '../../unlock_pdf/view/unlock_pdf_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(child: _HomeBody()),
          if (Platform.isAndroid) const BannerAdWidget(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Image.asset('assets/icon/app_icon.png', width: 32, height: 32),
      ),
      title: const Text(
        'DocFlow',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -0.5),
      ),
      actions: [
        Obx(() {
          if (ProService.to.isPro.value) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'PRO',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        IconButton(
          icon: const Icon(Icons.more_vert_rounded),
          onPressed: () => _showMenu(context),
        ),
      ],
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _MenuSheet(),
    );
  }
}

class _HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _HeroBanner()),
        // ── Recent Files ─────────────────────────────────────
        SliverToBoxAdapter(child: _RecentFilesSection()),
        // ── Tool List ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
            child: Text(
              'PDF TOOLS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildListDelegate(_buildToolItems()),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  List<Widget> _buildToolItems() {
    final tools = _toolDefinitions();
    return List.generate(tools.length, (i) {
      final t = tools[i];
      final isLast = i == tools.length - 1;
      return Column(
        children: [
          _ToolListItem(tool: t),
          if (!isLast)
            Divider(
              height: 1,
              indent: 72,
              color: Colors.grey.withValues(alpha: 0.15),
            ),
        ],
      );
    });
  }

  static List<_ToolDef> _toolDefinitions() => [
        _ToolDef(
          title: 'Image to PDF',
          subtitle: 'Convert photos & images to PDF',
          icon: Icons.image_rounded,
          color: AppColors.imageToPdf,
          onTap: () => Get.to(() => ImageToPdfView()),
        ),
        _ToolDef(
          title: 'Merge PDF',
          subtitle: 'Combine multiple PDFs into one',
          icon: Icons.merge_rounded,
          color: AppColors.mergePdf,
          onTap: () => Get.to(() => MergePdfView()),
        ),
        _ToolDef(
          title: 'Split PDF',
          subtitle: 'Extract pages from a PDF',
          icon: Icons.call_split_rounded,
          color: AppColors.splitPdf,
          onTap: () => Get.to(() => SplitPdfView()),
        ),
        _ToolDef(
          title: 'Compress PDF',
          subtitle: 'Reduce file size without quality loss',
          icon: Icons.compress_rounded,
          color: AppColors.compressPdf,
          onTap: () => Get.to(() => CompressPdfView()),
        ),
        _ToolDef(
          title: 'PDF to Image',
          subtitle: 'Export PDF pages as PNG images',
          icon: Icons.photo_library_rounded,
          color: AppColors.pdfToImage,
          onTap: () => Get.to(() => PdfToImageView()),
        ),
        _ToolDef(
          title: 'Protect PDF',
          subtitle: 'Lock PDF with a password',
          icon: Icons.lock_rounded,
          color: AppColors.protectPdf,
          onTap: () => Get.to(() => ProtectPdfView()),
        ),
        _ToolDef(
          title: 'Unlock PDF',
          subtitle: 'Remove password from a PDF',
          icon: Icons.lock_open_rounded,
          color: AppColors.unlockPdf,
          onTap: () => Get.to(() => UnlockPdfView()),
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Files Section
// ─────────────────────────────────────────────────────────────────────────────
class _RecentFilesSection extends StatelessWidget {
  static const _toolColors = {
    'image_to_pdf': AppColors.imageToPdf,
    'merge_pdf': AppColors.mergePdf,
    'split_pdf': AppColors.splitPdf,
    'compress_pdf': AppColors.compressPdf,
    'pdf_to_image': AppColors.pdfToImage,
    'protect_pdf': AppColors.protectPdf,
    'unlock_pdf': AppColors.unlockPdf,
  };

  static const _toolIcons = {
    'image_to_pdf': Icons.image_rounded,
    'merge_pdf': Icons.merge_rounded,
    'split_pdf': Icons.call_split_rounded,
    'compress_pdf': Icons.compress_rounded,
    'pdf_to_image': Icons.photo_library_rounded,
    'protect_pdf': Icons.lock_rounded,
    'unlock_pdf': Icons.lock_open_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final files = RecentFilesService.to.files;
      if (files.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              children: [
                Text(
                  'RECENT FILES',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.45),
                  ),
                ),
                const Spacer(),
                if (files.length > 1)
                  GestureDetector(
                    onTap: () {
                      // Clear all recent files
                      for (final f in [...files]) {
                        RecentFilesService.to.removeFile(f.id);
                      }
                    },
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.35),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 90,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: files.length,
              itemBuilder: (ctx, i) {
                final f = files[i];
                final color = _toolColors[f.tool] ?? AppColors.primary;
                final icon = _toolIcons[f.tool] ?? Icons.insert_drive_file_rounded;
                return _RecentFileChip(
                  file: f,
                  color: color,
                  icon: icon,
                );
              },
            ),
          ),
        ],
      );
    });
  }
}

class _RecentFileChip extends StatelessWidget {
  final RecentFile file;
  final Color color;
  final IconData icon;

  const _RecentFileChip({
    required this.file,
    required this.color,
    required this.icon,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        if (File(file.path).existsSync()) {
          OpenFilex.open(file.path);
        } else {
          RecentFilesService.to.removeFile(file.id);
          Get.snackbar('File Not Found', 'This file no longer exists');
        }
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 14),
                ),
                const Spacer(),
                Text(
                  _timeAgo(file.createdAt),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              file.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decoration circles
          Positioned(
            right: -20,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            right: 30,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'All PDF Tools\nIn One Place',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '7 powerful PDF tools in one app',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolDef {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolDef({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ToolListItem extends StatelessWidget {
  final _ToolDef tool;
  const _ToolListItem({required this.tool});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tool.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tool.color.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(tool.icon, color: tool.color, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tool.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tool.subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.25),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  static const _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.uksolutions.docflow';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: SingleChildScrollView(
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Obx(() {
            if (ProService.to.isPro.value) return const SizedBox.shrink();
            return Column(
              children: [
                _menuItem(
                  context,
                  icon: Icons.workspace_premium_rounded,
                  color: AppColors.primary,
                  title: 'Get DocFlow Pro',
                  subtitle: 'Remove all ads forever — \$1.99',
                  onTap: () {
                    Get.back();
                    ProUpgradeSheet.show();
                  },
                ),
                const SizedBox(height: 8),
              ],
            );
          }),
          _menuItem(
            context,
            icon: Icons.star_rounded,
            color: Colors.amber,
            title: 'Rate DocFlow',
            subtitle: 'Enjoying the app? Leave a review!',
            onTap: () async {
              Get.back();
              final inAppReview = InAppReview.instance;
              if (await inAppReview.isAvailable()) {
                inAppReview.requestReview();
              } else {
                launchUrl(Uri.parse(_playStoreUrl));
              }
            },
          ),
          const SizedBox(height: 8),
          _menuItem(
            context,
            icon: Icons.share_rounded,
            color: AppColors.imageToPdf,
            title: 'Share App',
            subtitle: 'Share DocFlow with friends',
            onTap: () {
              Get.back();
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'Try DocFlow – Smart PDF Tools! Free & powerful.\n$_playStoreUrl',
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _menuItem(
            context,
            icon: Icons.privacy_tip_rounded,
            color: AppColors.unlockPdf,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              Get.back();
              launchUrl(
                Uri.parse('https://uday0117.github.io/docflow-docs/privacy/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          const SizedBox(height: 8),
          _menuItem(
            context,
            icon: Icons.gavel_rounded,
            color: AppColors.splitPdf,
            title: 'Terms & Conditions',
            subtitle: 'Rules and guidelines for using the app',
            onTap: () {
              Get.back();
              launchUrl(
                Uri.parse('https://uday0117.github.io/docflow-docs/terms/'),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ],
      ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
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
              Expanded(
                child: Column(
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
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
