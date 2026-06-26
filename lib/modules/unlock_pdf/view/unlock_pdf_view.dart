import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_widget.dart';
import '../../../core/widgets/df_widgets.dart';
import '../controller/unlock_pdf_controller.dart';

class UnlockPdfView extends StatefulWidget {
  UnlockPdfView({super.key});

  @override
  State<UnlockPdfView> createState() => _UnlockPdfViewState();
}

class _UnlockPdfViewState extends State<UnlockPdfView> {
  final controller = Get.put(UnlockPdfController());
  final _pwdController = TextEditingController();
  bool _showPwd = false;

  static const _color = AppColors.unlockPdf;

  @override
  void dispose() {
    _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock PDF'), leading: const BackButton()),
      bottomNavigationBar: const BannerAdWidget(),
      body: Obx(() {
        final file = controller.selectedFile.value;
        final isLoading = controller.isLoading.value;
        final unlocked = controller.unlockedFile.value;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: DfToolHeader(
                title: 'Unlock PDF',
                subtitle: 'Remove password protection from PDF',
                icon: Icons.lock_open_rounded,
                color: _color,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfLoadingCard(
                      message: 'Removing password…', color: _color),
                ),
              )
            else if (unlocked != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DfResultCard(
                    message: 'PDF Unlocked!',
                    detail: 'Password protection removed',
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
                          label: 'Select a Protected PDF',
                          hint: 'Choose the password-protected\nPDF to unlock',
                          icon: Icons.picture_as_pdf_rounded,
                          color: _color,
                        )
                      : DfSelectedFileCard(
                          fileName: file.path.split('/').last,
                          subtitle: 'Password-protected PDF',
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
                    child: _PasswordInputCard(
                      pwdController: _pwdController,
                      showPwd: _showPwd,
                      onToggle: () =>
                          setState(() => _showPwd = !_showPwd),
                      color: _color,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: ElevatedButton.icon(
                      onPressed: isLoading
                          ? null
                          : () {
                              controller.password.value =
                                  _pwdController.text;
                              controller.unlockPdf();
                            },
                      icon: const Icon(Icons.lock_open_rounded),
                      label: const Text('Unlock PDF'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: _color),
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

class _PasswordInputCard extends StatelessWidget {
  final TextEditingController pwdController;
  final bool showPwd;
  final VoidCallback onToggle;
  final Color color;

  const _PasswordInputCard({
    required this.pwdController,
    required this.showPwd,
    required this.onToggle,
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
                'Enter Password',
                style:
                    TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: pwdController,
            obscureText: !showPwd,
            decoration: InputDecoration(
              labelText: 'PDF Password',
              hintText: 'Enter the password for this PDF',
              prefixIcon:
                  Icon(Icons.lock_outline_rounded, color: color),
              suffixIcon: IconButton(
                icon: Icon(showPwd
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded),
                onPressed: onToggle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
