import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/theme_provider.dart';
import 'data/models/onboarding_prefs.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/shell/main_shell.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar â€” immersive header look.
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Read first-launch state and saved theme before runApp to avoid flicker.
  final sp = await SharedPreferences.getInstance();
  final onboardingDone = sp.getBool('onboarding_done') ?? false;
  AppThemeChoice initialTheme = AppThemeChoice.darkRed;
  if (onboardingDone) {
    final name = sp.getString('onboarding_theme') ?? '';
    initialTheme = AppThemeChoice.values.firstWhere(
      (e) => e.name == name,
      orElse: () => AppThemeChoice.darkRed,
    );
  }

  // Initialize notifications (no-op on web).
  await NotificationService.instance.initialize();
  await NotificationService.instance.scheduleOnThisDayNotifications();

  runApp(
    ProviderScope(
      overrides: [initialThemeOverride(initialTheme)],
      child: KurdishCalendarApp(showOnboarding: !onboardingDone),
    ),
  );
}

class KurdishCalendarApp extends ConsumerWidget {
  final bool showOnboarding;

  const KurdishCalendarApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final light = ref.watch(lightThemeProvider);
    final dark = ref.watch(darkThemeProvider);

    return MaterialApp(
      title: 'Kurdish Calendar',
      debugShowCheckedModeBanner: false,
      theme: light,
      darkTheme: dark,
      themeMode: ThemeMode.dark,
      // RTL support for Kurdish.
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
      home: showOnboarding ? const OnboardingScreen() : const MainShell(),
    );
  }
}

