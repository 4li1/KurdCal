import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/kurdish_painters.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../data/models/calendar_event.dart';
import '../../../data/models/onboarding_prefs.dart';
import '../../../services/notification_service.dart';
import '../../../services/onboarding_service.dart';
import '../../shell/main_shell.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _isSaving = false;

  final Set<CategoryOption> _categories = {};
  AppThemeChoice _theme = AppThemeChoice.darkRed;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_page < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _finish() async {
    setState(() => _isSaving = true);

    final selectedCategories = _categories.map((e) => e.name).toList();
    debugPrint(
      'Onboarding save -> selectedCategories=$selectedCategories, selectedTheme=${_theme.name}',
    );

    // Apply immediately so UI updates without app restart.
    ref.read(themeChoiceProvider.notifier).setTheme(_theme);

    final prefs = OnboardingPrefs(
      categories: Set.from(_categories),
      theme: _theme,
    );

    await OnboardingService().savePrefs(prefs);

    // Apply onboarding category selection to notification preference flags.
    final notifPrefs = NotificationPrefs(
      enabled: _categories.isNotEmpty,
      holidays: _categories.contains(CategoryOption.holidays),
      tragedies: _categories.contains(CategoryOption.tragedies),
      // "Poetic / literature" maps to milestone-style historical highlights.
      milestones: _categories.contains(CategoryOption.poetic),
      cultural: _categories.contains(CategoryOption.cultural),
    );
    await NotificationService.instance.savePrefs(notifPrefs);
    await NotificationService.instance.scheduleOnThisDayNotifications();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const MainShell(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 450),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.loginGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 22),
              _DotIndicator(current: _page),
              const SizedBox(height: 18),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (value) => setState(() => _page = value),
                  children: [
                    _IntroSlide(onNext: _goNext),
                    _CategorySlide(
                      selected: _categories,
                      onToggle: (option) {
                        setState(() {
                          if (_categories.contains(option)) {
                            _categories.remove(option);
                          } else {
                            _categories.add(option);
                          }
                        });
                      },
                      onNext: _goNext,
                    ),
                    _ThemeSlide(
                      selected: _theme,
                      onSelect: (value) => setState(() => _theme = value),
                      isSaving: _isSaving,
                      onFinish: _finish,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int current;

  const _DotIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = index == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: active ? 20 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.sunGold : Colors.white.withOpacity(0.26),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _IntroSlide extends StatelessWidget {
  final VoidCallback onNext;

  const _IntroSlide({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
      child: Column(
        children: [
          const Spacer(),
          KurdishSunWidget(
            size: 136,
            color: AppColors.sunGold,
            glowColor: AppColors.sunGold.withOpacity(0.25),
            glowRadius: 22,
          )
              .animate()
              .fadeIn(duration: 700.ms)
              .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1)),
          const SizedBox(height: 22),
          Text(
            'Welcome to Kurdish Calendar',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.displaySmall!
                .copyWith(color: Colors.white),
          ).animate().fadeIn(delay: 120.ms, duration: 600.ms),
          const SizedBox(height: 12),
          Text(
            'This app helps you explore Kurdish dates, cultural events, holidays, and important historical moments. Stay connected with your culture and never miss important days.',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodyMedium!
                .copyWith(color: Colors.white.withOpacity(0.72), height: 1.6),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          const Spacer(),
          _PrimaryButton(
            text: 'Next',
            onPressed: onNext,
          ),
        ],
      ),
    );
  }
}

class _CategorySlide extends StatelessWidget {
  final Set<CategoryOption> selected;
  final ValueChanged<CategoryOption> onToggle;
  final VoidCallback onNext;

  const _CategorySlide({
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final options = CategoryOption.values;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
      child: Column(
        children: [
          Text(
            "Choose what you're interested in",
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.headlineLarge!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Select categories you want to see and get notifications about',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodySmall!
                .copyWith(color: Colors.white.withOpacity(0.62)),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final item = options[index];
                final isSelected = selected.contains(item);
                return _SelectableCard(
                  icon: item.icon,
                  titleKu: item.labelKu,
                  titleEn: item.labelEn,
                  selected: isSelected,
                  onTap: () => onToggle(item),
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: index * 80),
                      duration: 350.ms,
                    )
                    .slideY(
                      begin: 0.14,
                      end: 0,
                      delay: Duration(milliseconds: index * 80),
                      duration: 350.ms,
                    );
              },
            ),
          ),
          _PrimaryButton(text: 'Next', onPressed: onNext),
        ],
      ),
    );
  }
}

class _ThemeSlide extends StatelessWidget {
  final AppThemeChoice selected;
  final ValueChanged<AppThemeChoice> onSelect;
  final bool isSaving;
  final VoidCallback onFinish;

  const _ThemeSlide({
    required this.selected,
    required this.onSelect,
    required this.isSaving,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final options = AppThemeChoice.values;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
      child: Column(
        children: [
          Text(
            'Choose your app theme',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.headlineLarge!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Theme is applied instantly after setup.',
            textAlign: TextAlign.center,
            style: AppTypography.textTheme.bodySmall!
                .copyWith(color: Colors.white.withOpacity(0.62)),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options[index];
                return _ThemeCard(
                  option: option,
                  selected: selected == option,
                  onTap: () => onSelect(option),
                )
                    .animate()
                    .fadeIn(
                      delay: Duration(milliseconds: index * 80),
                      duration: 350.ms,
                    )
                    .slideY(
                      begin: 0.14,
                      end: 0,
                      delay: Duration(milliseconds: index * 80),
                      duration: 350.ms,
                    );
              },
            ),
          ),
          _PrimaryButton(
            text: 'Get Started',
            onPressed: isSaving ? null : onFinish,
            loading: isSaving,
          ),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final IconData icon;
  final String titleKu;
  final String titleEn;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.icon,
    required this.titleKu,
    required this.titleEn,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.sunGold.withOpacity(0.13)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.sunGold.withOpacity(0.7)
                : Colors.white.withOpacity(0.10),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.sunGold.withOpacity(0.22)
                    : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 22,
                color: selected
                    ? AppColors.sunGold
                    : Colors.white.withOpacity(0.72),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titleKu,
                    style: AppTypography.textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    titleEn,
                    style: AppTypography.textTheme.bodySmall!.copyWith(
                      color: Colors.white.withOpacity(0.46),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: selected ? AppColors.sunGold : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: selected
                      ? AppColors.sunGold
                      : Colors.white.withOpacity(0.4),
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 14, color: AppColors.inkDark)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemeChoice option;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  String _themeValueText(AppThemeChoice choice) => switch (choice) {
        AppThemeChoice.darkRed => '#5E0006',
        AppThemeChoice.deepBlue => '#003049',
        AppThemeChoice.green => '#5F8B4C',
        AppThemeChoice.brown => '#8C5A3C',
        AppThemeChoice.dynamic => 'Dynamic (changes based on weekday)',
      };

  @override
  Widget build(BuildContext context) {
    final isDynamic = option == AppThemeChoice.dynamic;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withOpacity(0.10)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.sunGold.withOpacity(0.7)
                : Colors.white.withOpacity(0.10),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDynamic ? null : option.seedColor,
                gradient: isDynamic
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF5E0006),
                          Color(0xFF003049),
                          Color(0xFF5F8B4C),
                          Color(0xFF8C5A3C),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                border: Border.all(
                  color: selected
                      ? AppColors.sunGold
                      : Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.labelEn,
                    style: AppTypography.textTheme.headlineSmall!.copyWith(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _themeValueText(option),
                    style: AppTypography.textTheme.bodySmall!.copyWith(
                      color: Colors.white.withOpacity(0.46),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.sunGold : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.sunGold
                      : Colors.white.withOpacity(0.4),
                ),
              ),
              child: selected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: AppColors.inkDark,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;

  const _PrimaryButton({
    required this.text,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sunGold,
          foregroundColor: AppColors.inkDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
          elevation: 8,
          shadowColor: AppColors.sunGold.withOpacity(0.35),
        ),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.inkDark,
                ),
              )
            : Text(
                text,
                style: AppTypography.textTheme.labelLarge!.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
      ),
    );
  }
}
