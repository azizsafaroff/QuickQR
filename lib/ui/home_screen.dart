import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'app_colors.dart';
import 'generate_tab.dart';
import 'history_tab.dart';
import 'scan_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBody: true,
      body: IndexedStack(
        index: _tab,
        children: [
          const GenerateTab(),
          _tab == 1 ? const ScanTab() : const SizedBox.shrink(),
          const HistoryTab(),
        ],
      ),
      bottomNavigationBar: _BottomBar(
        index: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 84,
          padding: const EdgeInsets.only(top: 12, left: 22, right: 22),
          decoration: const BoxDecoration(
            color: Color.fromRGBO(255, 255, 255, .92),
            border: Border(top: BorderSide(color: AppColors.cardBorder)),
          ),
          child: Row(
            children: [
              _BarItem(icon: LucideIcons.qrCode, label: 'Generate', active: index == 0, onTap: () => onChanged(0)),
              _BarItem(icon: LucideIcons.scanLine, label: 'Scan', active: index == 1, onTap: () => onChanged(1)),
              _BarItem(icon: LucideIcons.clock, label: 'History', active: index == 2, onTap: () => onChanged(2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({required this.icon, required this.label, required this.active, required this.onTap});

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.accent : AppColors.idleTab;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 5),
            Text(label, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}
