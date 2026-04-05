import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppColors.forestGreen,
        secondary: AppColors.sunGold,
        tertiary: AppColors.kurdishRed,
        surface: AppColors.creamSurface,
        onPrimary: Colors.white,
        onSecondary: AppColors.inkDark,
      ),
      scaffoldBackgroundColor: AppColors.creamBg,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.textTheme.headlineMedium!.copyWith(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: AppColors.creamSurface,
        elevation: 2,
        shadowColor: AppColors.inkDark.withOpacity(0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.creamSurface,
        selectedItemColor: AppColors.forestGreen,
        unselectedItemColor: AppColors.inkLight,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.forestGreen.withOpacity(0.1),
        labelStyle: AppTypography.textTheme.labelMedium!.copyWith(
          color: AppColors.forestGreen,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.forestGreen.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.creamBorder,
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.creamSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.creamBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.sunGold, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.sunGold,
        secondary: AppColors.forestGreenLight,
        tertiary: AppColors.kurdishRed,
        surface: AppColors.charcoalSurface,
        onPrimary: AppColors.inkDark,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.charcoalBg,
      textTheme: AppTypography.textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.textTheme.headlineMedium!.copyWith(
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: AppColors.charcoalSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.sunGold.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.charcoalSurface,
        selectedItemColor: AppColors.sunGold,
        unselectedItemColor: AppColors.inkLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.sunGold.withOpacity(0.1),
        labelStyle: AppTypography.textTheme.labelMedium!.copyWith(
          color: AppColors.sunGold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.sunGold.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withOpacity(0.06),
        thickness: 0.5,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.sunGold, width: 2),
        ),
      ),
    );
  }

  /// Generates a Kurdish-inspired [ThemeData] seeded from [primaryColor].
  /// Preserves the Kurdish design language (typography, surface colours)
  /// while swapping the primary accent to the user's chosen colour.
  static ThemeData fromSeed(Color primaryColor, {bool dark = true}) {
    final base = dark ? darkTheme : lightTheme;
    final scheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(
      // Keep Kurdish gold as the consistent secondary accent.
      secondary: AppColors.sunGold,
      // Preserve the hand-crafted Kurdish surface/background palette.
      surface: dark ? AppColors.charcoalSurface : AppColors.creamSurface,
    );
    return base.copyWith(colorScheme: scheme);
  }
}
