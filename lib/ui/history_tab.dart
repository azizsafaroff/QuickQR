import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../logic/scan_history_service.dart';
import 'app_colors.dart';
import 'utils/relative_time.dart';
import 'widgets/scan_result_sheet.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ScanHistoryService>();
    final history = service.history;

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
                    'History',
                    style: GoogleFonts.manrope(
                      fontSize: 27,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Your recent scans and codes.',
                    style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No scans yet',
                        style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textFaint),
                      ),
                    )
                  : ListView.separated(
                      itemCount: history.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 11),
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        final isUrl = service.isUrl(entry.value);
                        return _HistoryCard(
                          content: entry.value,
                          time: relativeTime(entry.scannedAt),
                          isLink: isUrl,
                          onTap: () => showScanResultSheet(context, value: entry.value),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.content, required this.time, required this.isLink, required this.onTap});

  final String content;
  final String time;
  final bool isLink;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLink ? AppColors.linkTint : AppColors.textTint,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  isLink ? LucideIcons.link : LucideIcons.fileText,
                  size: 21,
                  color: isLink ? AppColors.accent : AppColors.iconGray,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      time,
                      style: GoogleFonts.manrope(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.textFaint),
                    ),
                  ],
                ),
              ),
              const Icon(LucideIcons.chevronRight, color: AppColors.placeholderIcon),
            ],
          ),
        ),
      ),
    );
  }
}
