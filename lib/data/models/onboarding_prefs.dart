import 'package:flutter/material.dart';

/// All persisted choices from the first-launch onboarding flow.
class OnboardingPrefs {
  final Set<CategoryOption> categories;
  final AppThemeChoice theme;

  const OnboardingPrefs({
    this.categories = const {},
    this.theme = AppThemeChoice.darkRed,
  });

  OnboardingPrefs copyWith({
    Set<CategoryOption>? categories,
    AppThemeChoice? theme,
  }) =>
      OnboardingPrefs(
        categories: categories ?? this.categories,
        theme: theme ?? this.theme,
      );
}

// ── Category Options ──────────────────────────────────────────────────────

enum CategoryOption {
  holidays,
  tragedies,
  poetic,
  cultural;

  String get labelKu => switch (this) {
        CategoryOption.holidays => 'جەژنەکان',
        CategoryOption.tragedies => 'تراژیدیەکان',
        CategoryOption.poetic => 'شاعیرانە',
        CategoryOption.cultural => 'کەلتووری',
      };

  String get labelEn => switch (this) {
        CategoryOption.holidays => 'Holidays',
        CategoryOption.tragedies => 'Tragedies / historical events',
        CategoryOption.poetic => 'Poetic / literature',
        CategoryOption.cultural => 'Cultural',
      };

  IconData get icon => switch (this) {
        CategoryOption.holidays => Icons.celebration_rounded,
        CategoryOption.tragedies => Icons.history_edu_rounded,
        CategoryOption.poetic => Icons.auto_stories_rounded,
        CategoryOption.cultural => Icons.temple_buddhist_rounded,
      };
}

// ── Theme Choices ─────────────────────────────────────────────────────────

enum AppThemeChoice {
  darkRed,
  deepBlue,
  green,
  brown,
  dynamic;

  String get labelEn => switch (this) {
        AppThemeChoice.darkRed => 'Dark Red',
        AppThemeChoice.deepBlue => 'Deep Blue',
        AppThemeChoice.green => 'Green',
        AppThemeChoice.brown => 'Brown',
        AppThemeChoice.dynamic => 'Dynamic',
      };

  String get descEn => switch (this) {
        AppThemeChoice.darkRed => 'Bold & powerful',
        AppThemeChoice.deepBlue => 'Calm & focused',
        AppThemeChoice.green => 'Fresh & natural',
        AppThemeChoice.brown => 'Warm & traditional',
        AppThemeChoice.dynamic => 'Changes each day',
      };

  /// The primary seed color for this theme choice.
  Color get seedColor => switch (this) {
        AppThemeChoice.darkRed => const Color(0xFF5E0006),
        AppThemeChoice.deepBlue => const Color(0xFF003049),
        AppThemeChoice.green => const Color(0xFF5F8B4C),
        AppThemeChoice.brown => const Color(0xFF8C5A3C),
        AppThemeChoice.dynamic => _dynamicDayColor(),
      };

  static Color _dynamicDayColor() => switch (DateTime.now().weekday) {
        DateTime.monday => const Color(0xFF3A1A5C),
        DateTime.tuesday => const Color(0xFF004E64),
        DateTime.wednesday => const Color(0xFF3A5743),
        DateTime.thursday => const Color(0xFF6B3A00),
        DateTime.friday => const Color(0xFF0A2A4A),
        DateTime.saturday => const Color(0xFF2A0A4A),
        _ => const Color(0xFF5E0006),
      };
}
