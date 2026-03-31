import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kurdish Calendar — Typography System
/// Vazirmatn: Full Kurdish (Sorani/Kurmanji) + Latin Unicode support
/// Uses heavier weights for display/headlines to convey authority and prestige.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return TextTheme(
      // Display — Kurdish year, large headers (thick & authoritative)
      displayLarge: GoogleFonts.vazirmatn(
        fontSize: 40,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.2,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.vazirmatn(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
        height: 1.15,
      ),
      displaySmall: GoogleFonts.vazirmatn(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
      ),

      // Headlines — Month names, event titles (bold & clear)
      headlineLarge: GoogleFonts.vazirmatn(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.vazirmatn(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.vazirmatn(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.35,
      ),

      // Body — Descriptions, event content
      bodyLarge: GoogleFonts.vazirmatn(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.7,
      ),
      bodyMedium: GoogleFonts.vazirmatn(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        height: 1.4,
      ),

      // Labels — Navigation, chips, buttons
      labelLarge: GoogleFonts.vazirmatn(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
      labelMedium: GoogleFonts.vazirmatn(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      ),
      labelSmall: GoogleFonts.vazirmatn(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
    );
  }
}
