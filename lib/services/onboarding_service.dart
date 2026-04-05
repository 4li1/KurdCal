import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/onboarding_prefs.dart';

/// Handles persistence of the first-launch onboarding preferences.
class OnboardingService {
  static const _kDone = 'onboarding_done';
  static const _kCategories = 'onboarding_categories';
  static const _kTheme = 'onboarding_theme';

  /// Returns [true] when onboarding has never been completed.
  Future<bool> isFirstLaunch() async {
    final p = await SharedPreferences.getInstance();
    return !(p.getBool(_kDone) ?? false);
  }

  /// Persists all user choices and marks setup as done.
  Future<void> savePrefs(OnboardingPrefs data) async {
    final p = await SharedPreferences.getInstance();
    await p.setStringList(
        _kCategories, data.categories.map((e) => e.name).toList());
    await p.setString(_kTheme, data.theme.name);
    await p.setBool(_kDone, true);
  }

  /// Loads previously saved preferences. Returns [null] on first launch.
  Future<OnboardingPrefs?> loadPrefs() async {
    final p = await SharedPreferences.getInstance();
    if (!(p.getBool(_kDone) ?? false)) return null;

    final catNames = p.getStringList(_kCategories) ?? [];
    final themeName = p.getString(_kTheme) ?? AppThemeChoice.darkRed.name;

    return OnboardingPrefs(
      categories: catNames
          .map((n) => CategoryOption.values.firstWhere(
                (e) => e.name == n,
                orElse: () => CategoryOption.holidays,
              ))
          .toSet(),
      theme: AppThemeChoice.values.firstWhere(
        (e) => e.name == themeName,
        orElse: () => AppThemeChoice.darkRed,
      ),
    );
  }
}
