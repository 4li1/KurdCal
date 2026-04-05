import 'package:flutter/material.dart';

/// Custom [ThemeExtension] that carries three semantically-named colours for
/// each of the Kurdish Calendar theme presets.
///
/// Attach to every [ThemeData] so that any widget can read the correct value
/// with `Theme.of(context).extension<KurdishThemeExtension>()`.
///
/// The class is named [KurdishThemeExtension] rather than `AppColors` to
/// avoid a collision with the existing [AppColors] static-constants class.
class KurdishThemeExtension extends ThemeExtension<KurdishThemeExtension> {
  /// Highlight colour for the selected day circle in the calendar grid.
  /// Should be vivid and legible against the surface background.
  final Color primaryAccent;

  /// Background tint for the calendar grid and card surface panels.
  /// Tonally related to the theme primary but dark enough for depth.
  final Color surfaceColor;

  /// Text colour for large hero-headings and AppBar titles.
  /// Warm-tinted white variants for premium feel against dark gradients.
  final Color headerText;

  const KurdishThemeExtension({
    required this.primaryAccent,
    required this.surfaceColor,
    required this.headerText,
  });

  // ── Five static presets ───────────────────────────────────────────────

  /// Dark Red — bold, powerful. Seed #5E0006.
  static const red = KurdishThemeExtension(
    primaryAccent: Color(0xFFFF6B6B), // vivid coral-red accent
    surfaceColor:  Color(0xFF2A1215), // deep warm-dark red surface
    headerText:    Color(0xFFFFD6D6), // rose-tinted white
  );

  /// Deep Blue — calm, focused. Seed #003049.
  static const blue = KurdishThemeExtension(
    primaryAccent: Color(0xFF4DA6FF), // electric sky blue accent
    surfaceColor:  Color(0xFF0D1E2D), // deep navy surface
    headerText:    Color(0xFFD0E8FF), // cool pale-blue white
  );

  /// Forest Green — fresh, natural. Seed #5F8B4C.
  static const green = KurdishThemeExtension(
    primaryAccent: Color(0xFF6FCF97), // fresh mint accent
    surfaceColor:  Color(0xFF0F1E13), // deep forest surface
    headerText:    Color(0xFFD4F0C4), // soft sage-green white
  );

  /// Brown — warm, traditional. Seed #8C5A3C.
  static const brown = KurdishThemeExtension(
    primaryAccent: Color(0xFFD4956B), // terracotta-amber accent
    surfaceColor:  Color(0xFF211108), // deep dark-wood surface
    headerText:    Color(0xFFFFE5CC), // warm cream
  );

  /// Dynamic/Yellow — golden, celebratory. Kurdish sun gold.
  static const yellow = KurdishThemeExtension(
    primaryAccent: Color(0xFFFFD700), // Kurdish sun gold
    surfaceColor:  Color(0xFF1E1A00), // deep gold-tinted surface
    headerText:    Color(0xFFFFF9E6), // champagne white
  );

  // ── ThemeExtension contract ───────────────────────────────────────────

  @override
  KurdishThemeExtension copyWith({
    Color? primaryAccent,
    Color? surfaceColor,
    Color? headerText,
  }) =>
      KurdishThemeExtension(
        primaryAccent: primaryAccent ?? this.primaryAccent,
        surfaceColor:  surfaceColor  ?? this.surfaceColor,
        headerText:    headerText    ?? this.headerText,
      );

  @override
  KurdishThemeExtension lerp(KurdishThemeExtension? other, double t) {
    if (other == null) return this;
    return KurdishThemeExtension(
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      surfaceColor:  Color.lerp(surfaceColor,  other.surfaceColor,  t)!,
      headerText:    Color.lerp(headerText,    other.headerText,    t)!,
    );
  }
}
