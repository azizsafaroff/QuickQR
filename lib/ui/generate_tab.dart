import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../logic/qr_generator_service.dart';
import 'app_colors.dart';
import 'widgets/copied_toast.dart';

class GenerateTab extends StatefulWidget {
  const GenerateTab({super.key});

  @override
  State<GenerateTab> createState() => _GenerateTabState();
}

class _GenerateTabState extends State<GenerateTab> {
  final GlobalKey _qrBoundaryKey = GlobalKey();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final service = context.read<QrGeneratorService>();
    _controller = TextEditingController(text: service.text)
      ..addListener(() => service.updateText(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<Uint8List?> _captureQrImage() async {
    final boundary =
        _qrBoundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _onSave() async {
    final bytes = await _captureQrImage();
    if (bytes == null || !mounted) return;
    await context.read<QrGeneratorService>().saveImageToGallery(bytes);
    if (mounted) showCopiedToast(context, 'Saved to gallery');
  }

  Future<void> _onShare() async {
    final bytes = await _captureQrImage();
    if (bytes == null || !mounted) return;
    await context.read<QrGeneratorService>().shareImage(bytes);
  }

  @override
  Widget build(BuildContext context) {
    final service = context.watch<QrGeneratorService>();
    if (_controller.text != service.text) {
      _controller.value = _controller.value.copyWith(
        text: service.text,
        selection: TextSelection.collapsed(offset: service.text.length),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Generate',
                    style: GoogleFonts.manrope(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Type or paste anything to create a code.',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(20, 30, 28, .08),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter a link or text…',
                        hintStyle: GoogleFonts.manrope(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textFaint,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                  _RoundIconButton(
                    icon: LucideIcons.clipboard,
                    tooltip: 'Paste',
                    onTap: context
                        .read<QrGeneratorService>()
                        .pasteFromClipboard,
                  ),
                  const SizedBox(width: 6),
                  _RoundIconButton(
                    icon: LucideIcons.x,
                    tooltip: 'Clear',
                    onTap: context.read<QrGeneratorService>().clear,
                  ),
                ],
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Container(
                          width: 300,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          padding: const EdgeInsets.all(26),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.cardBorder),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(20, 30, 28, .12),
                                blurRadius: 30,
                                offset: Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RepaintBoundary(
                                key: _qrBoundaryKey,
                                child: Container(
                                  width: 244,
                                  height: 244,
                                  color: Colors.white,
                                  child: service.hasText
                                      ? QrImageView(
                                          data: service.text,
                                          size: 244,
                                          padding: EdgeInsets.zero,
                                        )
                                      : _EmptyQrPlaceholder(),
                                ),
                              ),
                              if (service.hasText) ...[
                                const SizedBox(height: 18),
                                Text(
                                  service.text,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 12.5,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: service.hasText ? _onSave : null,
                      icon: const Icon(LucideIcons.download, size: 20),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.accent.withValues(
                          alpha: .4,
                        ),
                        disabledForegroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: GoogleFonts.manrope(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: service.hasText ? _onShare : null,
                      icon: const Icon(LucideIcons.share2, size: 20),
                      label: const Text('Share'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textDark,
                        side: const BorderSide(color: AppColors.cardBorder2),
                        minimumSize: const Size.fromHeight(54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: GoogleFonts.manrope(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyQrPlaceholder extends StatelessWidget {
  const _EmptyQrPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.placeholderBg,
        border: Border.all(color: AppColors.dashedBorder, width: 1.5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            LucideIcons.qrCode,
            size: 46,
            color: AppColors.placeholderIcon,
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Enter text or a link to generate your QR code',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textFaint,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, size: 19, color: AppColors.iconGray),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.neutralBtnBg,
        minimumSize: const Size(38, 38),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
