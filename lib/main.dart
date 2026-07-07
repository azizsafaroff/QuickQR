import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'logic/qr_generator_service.dart';
import 'logic/scan_history_service.dart';
import 'ui/app_colors.dart';
import 'ui/home_screen.dart';

void main() {
  runApp(const QuickQrApp());
}

class QuickQrApp extends StatelessWidget {
  const QuickQrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QrGeneratorService()),
        ChangeNotifierProvider(create: (_) => ScanHistoryService()),
      ],
      child: MaterialApp(
        title: 'QuickQR',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
          scaffoldBackgroundColor: AppColors.scaffoldBg,
          textTheme: GoogleFonts.manropeTextTheme(),
          useMaterial3: true,
        ),
        builder: (context, child) => GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: child,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
