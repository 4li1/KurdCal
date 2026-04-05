import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/onboarding_prefs.dart';
import 'app_theme.dart';

// Internal provider — overridden in ProviderScope.overrides to pass the
// initial theme from main() into the provider graph without async.
final _initialThemeProvider =
    Provider<AppThemeChoice>((_) => AppThemeChoice.darkRed);

/// The active theme choice; updated when onboarding completes.
final themeChoiceProvider =
    NotifierProvider<_ThemeChoiceNotifier, AppThemeChoice>(
  _ThemeChoiceNotifier.new,
);

class _ThemeChoiceNotifier extends Notifier<AppThemeChoice> {
  @override
  AppThemeChoice build() => ref.read(_initialThemeProvider);

  void setTheme(AppThemeChoice choice) => state = choice;
}

/// Convenience factory to use inside [ProviderScope.overrides] in [main].
Override initialThemeOverride(AppThemeChoice choice) =>
    _initialThemeProvider.overrideWithValue(choice);

/// Derived [ThemeData] providers consumed directly by [MaterialApp].
final lightThemeProvider = Provider<ThemeData>((ref) {
  final choice = ref.watch(themeChoiceProvider);
  return AppTheme.fromSeed(choice, dark: false);
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  final choice = ref.watch(themeChoiceProvider);
  return AppTheme.fromSeed(choice, dark: true);
});
