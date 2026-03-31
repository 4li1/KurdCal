import 'package:flutter/material.dart';

/// Kurdistan Calendar — Pure Kurdish Design System Colors
/// Derived from the Kurdish flag, Zagros landscape, and traditional Kilim textiles.
class AppColors {
  AppColors._();

  // ── Primary Palette (Kurdish National Colors — Premium) ──────────────────
  static const Color kurdishRed = Color(0xFF8E1B1B);       // Deep Kurdish Red
  static const Color kurdishRedLight = Color(0xFFB22A2A);  // Lighter accent
  static const Color sunGold = Color(0xFFFFD700);          // Golden Sun Yellow
  static const Color sunGoldDeep = Color(0xFFD4A017);      // Deeper gold
  static const Color sunGoldMuted = Color(0xFFE8C547);     // Muted gold
  static const Color forestGreen = Color(0xFF138808);      // Forest Green
  static const Color forestGreenLight = Color(0xFF2AAA1B); // Light green accent
  static const Color pureWhite = Color(0xFFFFFFFF);

  // ── Charcoal Dark Mode ──────────────────────────────────────────────────
  static const Color charcoalBg = Color(0xFF1A1A2E);       // Deep charcoal bg
  static const Color charcoalSurface = Color(0xFF252540);   // Card/surface
  static const Color charcoalElevated = Color(0xFF2F2F4A);  // Elevated panels
  static const Color charcoalLight = Color(0xFF3A3A5C);     // Borders/dividers

  // ── Cream Light Mode ────────────────────────────────────────────────────
  static const Color creamBg = Color(0xFFFFF8F0);          // Warm cream bg
  static const Color creamSurface = Color(0xFFFFF3E6);     // Cards
  static const Color creamElevated = Color(0xFFFFEDD5);    // Elevated
  static const Color creamBorder = Color(0xFFE8D5B8);      // Subtle borders

  // ── Earthy / Cultural ───────────────────────────────────────────────────
  static const Color zagrosEarth = Color(0xFF6B4226);
  static const Color rugTan = Color(0xFFB3895A);
  static const Color kilimBrown = Color(0xFF8B6E4E);

  // ── Text ────────────────────────────────────────────────────────────────
  static const Color inkDark = Color(0xFF1A1218);
  static const Color inkMedium = Color(0xFF5C4A5A);
  static const Color inkLight = Color(0xFF9E8FA0);
  static const Color textOnDark = Color(0xFFF5F0E8);

  // ── Event Type Colors ───────────────────────────────────────────────────
  static const Color eventHoliday = forestGreen;
  static const Color eventTragedy = kurdishRed;
  static const Color eventMilestone = sunGold;
  static const Color eventCultural = zagrosEarth;

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF43AA8B);
  static const Color warning = Color(0xFFFFB703);
  static const Color error = kurdishRed;

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient headerGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [forestGreen, Color(0xFF0A6B04)],
  );

  static const LinearGradient headerGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [charcoalBg, Color(0xFF16162B)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [sunGold, sunGoldDeep],
  );

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A1A2E), Color(0xFF16162B), Color(0xFF0F0F1E)],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [kurdishRed, Color(0xFF6B1414)],
  );

  /// Returns the Kurdish flag strip colors (Red, White, Green, Gold)
  static const List<Color> flagStripColors = [
    kurdishRed,
    pureWhite,
    forestGreen,
    sunGold,
  ];
}
