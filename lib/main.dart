import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_typography.dart';
import 'core/theme/kurdish_painters.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/history/screens/history_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Make status bar transparent (for the immersive header)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize notification service
  await NotificationService.instance.initialize();

  // Schedule "on this day" notifications for the next 30 days
  await NotificationService.instance.scheduleOnThisDayNotifications();

  runApp(
    const ProviderScope(
      child: KurdishCalendarApp(),
    ),
  );
}

class KurdishCalendarApp extends ConsumerWidget {
  const KurdishCalendarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ساڵنامەی کوردستان',  // Kurdistan Calendar
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Default dark for the Kurdish aesthetic
      // RTL support for Kurdish
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AppEntryPoint(),
    );
  }
}

/// Entry point: shows login first, then main shell.
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    if (!_isLoggedIn) {
      return LoginScreen(
        onLoginSuccess: () {
          setState(() => _isLoggedIn = true);
        },
      );
    }
    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late final PageController _pageController;

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon: Icons.wb_sunny_outlined,
      activeIcon: Icons.wb_sunny,
      labelKu: 'ساڵنامە',
      labelEn: 'Calendar',
      useSunIcon: true,
    ),
    _NavItem(
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      labelKu: 'مێژوو',
      labelEn: 'History',
    ),
    _NavItem(
      icon: Icons.notifications_outlined,
      activeIcon: Icons.notifications,
      labelKu: 'ئاگادارکردن',
      labelEn: 'Alerts',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings,
      labelKu: 'ڕێکخستن',
      labelEn: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (_currentIndex != index) {
      setState(() => _currentIndex = index);
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          CalendarScreen(),
          HistoryScreen(),
          _AlertsPlaceholder(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalSurface : AppColors.creamSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.sunGold.withOpacity(0.1)
                  : AppColors.creamBorder,
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final item = _navItems[index];
                final isActive = index == _currentIndex;
                return _KurdishNavItem(
                  item: item,
                  isActive: isActive,
                  isDark: isDark,
                  onTap: () => _onNavTap(index),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

/// Custom nav item with golden glow for active state
class _KurdishNavItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final bool isDark;
  final VoidCallback onTap;

  const _KurdishNavItem({
    required this.item,
    required this.isActive,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark ? AppColors.sunGold : AppColors.forestGreen;
    final inactiveColor = AppColors.inkLight;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: activeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.useSunIcon)
              KurdishSunWidget(
                size: 24,
                color: isActive ? activeColor : inactiveColor,
              )
            else
              Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
            const SizedBox(height: 4),
            Text(
              item.labelKu,
              style: AppTypography.textTheme.labelSmall!.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelKu;
  final String labelEn;
  final bool useSunIcon;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelKu,
    required this.labelEn,
    this.useSunIcon = false,
  });
}

class _AlertsPlaceholder extends StatelessWidget {
  const _AlertsPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          KurdishSunWidget(
            size: 48,
            color: AppColors.sunGold.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'ئاگادارکردنەوەکان',
            style: AppTypography.textTheme.headlineMedium!.copyWith(
              color: isDark ? Colors.white54 : AppColors.inkLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alerts — Coming Soon',
            style: AppTypography.textTheme.bodySmall!.copyWith(
              color: AppColors.inkLight,
            ),
          ),
        ],
      ),
    );
  }
}
