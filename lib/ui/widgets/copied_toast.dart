import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../app_colors.dart';

void showCopiedToast(BuildContext context, [String message = 'Copied to clipboard']) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
        ),
        backgroundColor: AppColors.toastBg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        margin: const EdgeInsets.only(bottom: 110, left: 60, right: 60),
      ),
    );
}
