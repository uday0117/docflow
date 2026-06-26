import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/df_widgets.dart';
import '../controller/protect_pdf_controller.dart';

class ProtectPdfView extends StatefulWidget {
  ProtectPdfView({super.key});

  @override
  State<ProtectPdfView> createState() => _ProtectPdfViewState();
}

class _ProtectPdfViewState extends State<ProtectPdfView> {
  final controller = Get.put(ProtectPdfController());
  final _pwdController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPwd = false;
  bool _showConfirm = false;

  static const _color = AppColors.protectPdf;

  @override
  void dispose() {
    _pwdController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protect PDF'), leading: const BackButton()),
      bottomNavigationBar: const BannerAdWidget(),
      body: Obx(() {
        final file = controller.selectedFile.value;
        final isProcessing = controller.isProcessing.value;
        final protected = controller.protectedFile.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfToolHeader(
                title: 'Protect PDF',
                subtitle: 'Lock your PDF with a password',
                icon: Icons.lock_rounded,
                color: _color,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (isProcessing)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfLoadingCard(message: 'Encrypting PDF…', color: _color),
                ),
              )
            else if (protected != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfResultCard(
                    message: 'PDF Protected!',
                    detail: 'Your PDF is now password-protected',
                    onOpen: () {},
                    onShare: () {},
                    color: _color,
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
                          hint: 'Choose the PDF to\npassword-protect',
                          icon: Icons.picture_as_pdf_rounded,
                          color: _color,
                        )
                      : DfSelectedFileCard(
                          fileName: file.path.split('/').last,
                          color: _color,
                          onRemove: () {
                            controller.selectedFile.value = null;
                          },
                        ),
                ),
              ),
              if (file != null) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _PasswordCard(
                      pwdController: _pwdController,
                      confirmController: _confirmController,
                      showPwd: _showPwd,
                      showConfirm: _showConfirm,
                      onTogglePwd: () =>
                          setState(() => _showPwd = !_showPwd),
                      onToggleConfirm: () =>
                          setState(() => _showConfirm = !_showConfirm),
                      color: _color,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () {
                              final pwd = _pwdController.text.trim();
                              final confirm = _confirmController.text.trim();
                              if (pwd != confirm) {
                                Get.snackbar(
                                    'Error', 'Passwords do not match');
                                return;
                              }
                              controller.protectPdf(pwd);
                            },
                      icon: const Icon(Icons.lock_rounded),
                      label: const Text('Protect PDF'),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: _color),
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

class _PasswordCard extends StatelessWidget {
  final TextEditingController pwdController;
  final TextEditingController confirmController;
  final bool showPwd;
  final bool showConfirm;
  final VoidCallback onTogglePwd;
  final VoidCallback onToggleConfirm;
  final Color color;

  const _PasswordCard({
    required this.pwdController,
    required this.confirmController,
    required this.showPwd,
    required this.showConfirm,
    required this.onTogglePwd,
    required this.onToggleConfirm,
    required this.color,
  });

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.key_rounded, color: color, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Set Password',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pwdController,
            obscureText: !showPwd,
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded, color: color),
              suffixIcon: IconButton(
                icon: Icon(showPwd
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: onTogglePwd,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: confirmController,
            obscureText: !showConfirm,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              prefixIcon:
                  Icon(Icons.lock_outline_rounded, color: color),
              suffixIcon: IconButton(
                icon: Icon(showConfirm
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: onToggleConfirm,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: color, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Use a strong password. You cannot open the PDF without it.',
                    style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500),
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
