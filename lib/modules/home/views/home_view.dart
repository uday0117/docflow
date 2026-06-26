import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
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
                        '7 powerful tools, completely free',
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
