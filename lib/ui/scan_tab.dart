import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../logic/scan_history_service.dart';
import 'app_colors.dart';
import 'widgets/scan_result_sheet.dart';
import 'widgets/scanner_overlay.dart';

class ScanTab extends StatefulWidget {
  const ScanTab({super.key});

  @override
  State<ScanTab> createState() => _ScanTabState();
}

class _ScanTabState extends State<ScanTab> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _sheetShowing = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> _showResult(String value) async {
    if (_sheetShowing) return;
    _sheetShowing = true;
    await context.read<ScanHistoryService>().addScan(value);
    if (mounted) await showScanResultSheet(context, value: value);
    _sheetShowing = false;
  }

  void _onDetect(BarcodeCapture capture) {
    final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (raw == null || raw.isEmpty) return;
    _showResult(raw);
  }

  Future<void> _scanFromGallery() async {
    final service = context.read<ScanHistoryService>();
    final path = await service.pickImageFromGallery();
    if (path == null || !mounted) return;
    final value = await service.scanImageFile(path);
    if (!mounted) return;
    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code found in that image')),
      );
      return;
    }
    await showScanResultSheet(context, value: value);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -.4),
              radius: 1.1,
              colors: [AppColors.scanBgTop, AppColors.scanBgMid, AppColors.scanBgBottom],
              stops: [0, .7, 1],
            ),
          ),
        ),
        MobileScanner(controller: _cameraController, onDetect: _onDetect, fit: BoxFit.cover),
        const ScannerOverlay(),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 26),
            child: Text(
              'Point your camera at a QR code',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600, color: const Color.fromRGBO(255, 255, 255, .82)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 118,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: _scanFromGallery,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, .14),
                      border: Border.all(color: const Color.fromRGBO(255, 255, 255, .18)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(LucideIcons.image, color: Colors.white, size: 26),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Gallery',
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: const Color.fromRGBO(255, 255, 255, .62)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
