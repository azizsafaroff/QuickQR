import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../logic/scan_history_service.dart';
import '../app_colors.dart';
import 'copied_toast.dart';

Future<void> showScanResultSheet(
  BuildContext context, {
  required String value,
}) {
  final isUrl = context.read<ScanHistoryService>().isUrl(value);
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (sheetContext) => _ScanResultSheet(value: value, isUrl: isUrl),
  );
}

class _ScanResultSheet extends StatelessWidget {
  const _ScanResultSheet({required this.value, required this.isUrl});

  final String value;
  final bool isUrl;

  @override
  Widget build(BuildContext context) {
    final service = context.read<ScanHistoryService>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: AppColors.dashedBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.linkTint,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(LucideIcons.check, size: 19, color: AppColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'QR code detected',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(LucideIcons.x, size: 17, color: AppColors.iconGray),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.neutralBtnBg,
                  minimumSize: const Size(34, 34),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.sheetContentBg,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUrl ? 'LINK' : 'TEXT',
                  style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .5,
                    color: AppColors.textFaint,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: isUrl ? 10 : 1,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await service.copyToClipboard(value);
                    if (context.mounted) showCopiedToast(context);
                  },
                  icon: const Icon(LucideIcons.copy, size: 19),
                  label: const Text('Copy'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textDark,
                    side: const BorderSide(color: AppColors.cardBorder2),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              if (isUrl) ...[
                const SizedBox(width: 12),
                Expanded(
                  flex: 13,
                  child: ElevatedButton.icon(
                    onPressed: () => service.openUrl(value),
                    icon: const Icon(LucideIcons.externalLink, size: 19),
                    label: const Text('Open Link'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      textStyle: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
