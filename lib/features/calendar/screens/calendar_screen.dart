import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/kurdish_painters.dart';
import '../../../core/theme/kurdish_theme_extension.dart';
import '../../../core/constants/kurdish_months.dart';
import '../../../core/utils/calendar_converter.dart';
import '../../../data/models/calendar_event.dart';
import '../../../services/notification_service.dart';

// ── Providers ──────────────────────────────────────────────────────────────

/// Active calendar system (Kurdish / Gregorian / Hijri)
final calendarSystemProvider = StateProvider<CalendarSystem>(
  (ref) => CalendarSystem.kurdish,
);

/// The currently displayed month as a Gregorian DateTime (first of month)
final displayedMonthProvider = StateProvider<DateTime>(
  (ref) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  },
);

/// Currently selected date
final selectedDateProvider = StateProvider<DateTime>(
  (ref) => DateTime.now(),
);

// ── Calendar Screen ────────────────────────────────────────────────────────

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _CalendarHeader(),
          SliverToBoxAdapter(child: _CalendarSystemToggle()),
          SliverToBoxAdapter(child: _WeekdayHeaders()),
          SliverToBoxAdapter(child: _CalendarGrid()),
          SliverToBoxAdapter(child: _TodaysEventsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ── Header SliverAppBar ────────────────────────────────────────────────────

class _CalendarHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedMonth = ref.watch(displayedMonthProvider);
    final calSystem = ref.watch(calendarSystemProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<KurdishThemeExtension>();
    final headerStart = Color.lerp(
      scheme.primary,
      isDark ? AppColors.charcoalBg : Colors.white,
      isDark ? 0.25 : 0.15,
    )!;
    final headerEnd = Color.lerp(
      scheme.primary,
      isDark ? Colors.black : AppColors.forestGreen,
      isDark ? 0.55 : 0.25,
    )!;
    final titleColor = ext?.headerText ?? Colors.white;

    final kurdishDate = CalendarConverter.gregorianToKurdish(
      displayedMonth.year,
      displayedMonth.month,
      1,
    );
    final kurdishMonth = KurdishMonths.byNumber(kurdishDate.month);

    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      stretch: true,
      backgroundColor: scheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.fadeTitle,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [headerStart, headerEnd],
                ),
              ),
            ),
            // Kilim pattern overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: KilimBorderWidget(
                height: 45,
                color: AppColors.sunGold,
                opacity: isDark ? 0.05 : 0.08,
              ),
            ),
            // Small sun watermark
            Positioned(
              left: 20,
              bottom: 60,
              child: Opacity(
                opacity: 0.06,
                child: KurdishSunWidget(
                  size: 120,
                  color: AppColors.sunGold,
                ),
              ),
            ),
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Year display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _buildYearDisplay(calSystem, displayedMonth, kurdishDate),
                          style: AppTypography.textTheme.displayMedium!.copyWith(
                            color: titleColor,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        // Sun icon badge
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.sunGold.withOpacity(0.3),
                            ),
                          ),
                          child: const Center(
                            child: KurdishSunWidget(
                              size: 22,
                              color: AppColors.sunGold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Month name
                    Text(
                      _buildMonthDisplay(calSystem, displayedMonth, kurdishMonth),
                      style: AppTypography.textTheme.headlineMedium!.copyWith(
                        color: (ext?.headerText ?? Colors.white).withOpacity(0.9),
                      ),
                    ),
                    // Navigation arrows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _MonthNavButton(
                          icon: Icons.chevron_right,
                          onTap: () => _adjustMonth(ref, -1),
                        ),
                        const SizedBox(width: 8),
                        _MonthNavButton(
                          icon: Icons.chevron_left,
                          onTap: () => _adjustMonth(ref, 1),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildYearDisplay(
    CalendarSystem system,
    DateTime date,
    KurdishDate kDate,
  ) {
    switch (system) {
      case CalendarSystem.kurdish:
        return '${kDate.year}';
      case CalendarSystem.gregorian:
        return '${date.year}';
      case CalendarSystem.hijri:
        final hijri = CalendarConverter.gregorianToHijri(
          date.year, date.month, date.day);
        return '${hijri.year}';
    }
  }

  String _buildMonthDisplay(
    CalendarSystem system,
    DateTime date,
    KurdishMonth kMonth,
  ) {
    switch (system) {
      case CalendarSystem.kurdish:
        return kMonth.nameSorani;
      case CalendarSystem.gregorian:
        const months = [
          'January', 'February', 'March', 'April', 'May', 'June',
          'July', 'August', 'September', 'October', 'November', 'December'
        ];
        return months[date.month - 1];
      case CalendarSystem.hijri:
        final hijri = CalendarConverter.gregorianToHijri(
          date.year, date.month, date.day);
        return HijriDate.monthNames[hijri.month - 1];
    }
  }

  void _adjustMonth(WidgetRef ref, int delta) {
    final current = ref.read(displayedMonthProvider);
    ref.read(displayedMonthProvider.notifier).state = DateTime(
      current.year,
      current.month + delta,
      1,
    );
  }
}

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.sunGold.withOpacity(0.3),
          ),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ── Calendar System Toggle ─────────────────────────────────────────────────

class _CalendarSystemToggle extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CalendarSystemToggle> createState() =>
      _CalendarSystemToggleState();
}

class _CalendarSystemToggleState extends ConsumerState<_CalendarSystemToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeSystem = ref.watch(calendarSystemProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final systems = CalendarSystem.values;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalSurface : AppColors.creamSurface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark
                ? AppColors.sunGold.withOpacity(0.1)
                : AppColors.creamBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated gold indicator pill
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: _pillAlignment(activeSystem),
              child: FractionallySizedBox(
                widthFactor: 1 / 3,
                heightFactor: 0.85,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.sunGold.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Labels
            Row(
              children: systems.map((system) {
                final isActive = system == activeSystem;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ref.read(calendarSystemProvider.notifier).state = system;
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: AppTypography.textTheme.labelLarge!.copyWith(
                          color: isActive
                              ? AppColors.inkDark
                              : (isDark ? Colors.white54 : AppColors.inkMedium),
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w500,
                        ),
                        child: Text(system.labelSorani),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Alignment _pillAlignment(CalendarSystem system) {
    switch (system) {
      case CalendarSystem.kurdish:    return Alignment.centerRight;
      case CalendarSystem.gregorian: return Alignment.center;
      case CalendarSystem.hijri:     return Alignment.centerLeft;
    }
  }
}

// ── Weekday Headers ────────────────────────────────────────────────────────

class _WeekdayHeaders extends ConsumerWidget {
  static const _weekdaysKu = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ھ'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: _weekdaysKu.map((day) {
          return Expanded(
            child: Center(
              child: Text(
                day,
                style: AppTypography.textTheme.labelMedium!.copyWith(
                  color: isDark ? Colors.white38 : AppColors.inkLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Calendar Grid ──────────────────────────────────────────────────────────

class _CalendarGrid extends ConsumerWidget {
  // Demo events — replace with actual DB query in production
  static final _demoEventDays = {
    21: EventType.holiday,   // Newroz
    16: EventType.tragedy,   // Halabja anniversary (if March)
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayedMonth = ref.watch(displayedMonthProvider);
    final selectedDate = ref.watch(selectedDateProvider);
    final calSystem = ref.watch(calendarSystemProvider);

    final firstDay = DateTime(displayedMonth.year, displayedMonth.month, 1);
    final daysInMonth =
        DateTime(displayedMonth.year, displayedMonth.month + 1, 0).day;

    // Kurdish week starts on Saturday (Şembe / شەممە)
    int startWeekday = firstDay.weekday;
    int offset = (startWeekday - 6 + 7) % 7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).extension<KurdishThemeExtension>()?.surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(scale: anim.drive(Tween(begin: 0.95, end: 1.0)), child: child),
        ),
        child: GridView.builder(
          key: ValueKey('${displayedMonth.year}-${displayedMonth.month}-$calSystem'),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1,
          ),
          itemCount: offset + daysInMonth,
          itemBuilder: (context, index) {
            if (index < offset) return const SizedBox.shrink();
            final day = index - offset + 1;
            final date = DateTime(
              displayedMonth.year,
              displayedMonth.month,
              day,
            );
            final isToday = _isSameDay(date, DateTime.now());
            final isSelected = _isSameDay(date, selectedDate);
            final eventType = _demoEventDays[day];

            return _DayCell(
              date: date,
              day: day,
              isToday: isToday,
              isSelected: isSelected,
              eventType: eventType,
              calSystem: calSystem,
              onTap: () {
                ref.read(selectedDateProvider.notifier).state = date;
              },
            );
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ── Day Cell ───────────────────────────────────────────────────────────────

class _DayCell extends StatefulWidget {
  final DateTime date;
  final int day;
  final bool isToday;
  final bool isSelected;
  final EventType? eventType;
  final CalendarSystem calSystem;
  final VoidCallback onTap;

  const _DayCell({
    required this.date,
    required this.day,
    required this.isToday,
    required this.isSelected,
    required this.eventType,
    required this.calSystem,
    required this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell>
    with SingleTickerProviderStateMixin {
  late AnimationController _tapController;

  @override
  void initState() {
    super.initState();
    _tapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _tapController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _tapController.reverse();
    widget.onTap();
    await _tapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ext = Theme.of(context).extension<KurdishThemeExtension>();
    final accent = ext?.primaryAccent ?? AppColors.sunGold;

    Color? bgColor;
    Color textColor = isDark ? Colors.white : AppColors.inkDark;
    bool hasRing = false;

    if (widget.isSelected) {
      bgColor = accent;
      textColor = AppColors.inkDark;
    } else if (widget.isToday) {
      hasRing = true;
      textColor = accent;
    }

    final displayNum = _getDayLabel(widget.date, widget.calSystem, widget.day);

    return GestureDetector(
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _tapController,
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: hasRing
                ? Border.all(color: accent, width: 2)
                : null,
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: accent.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayNum,
                style: AppTypography.textTheme.bodyMedium!.copyWith(
                  color: textColor,
                  fontWeight:
                      widget.isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              if (widget.eventType != null)
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: _eventDotColor(widget.eventType!),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _eventDotColor(EventType type) {
    switch (type) {
      case EventType.holiday:   return AppColors.eventHoliday;
      case EventType.tragedy:   return AppColors.eventTragedy;
      case EventType.milestone: return AppColors.eventMilestone;
      case EventType.cultural:  return AppColors.eventCultural;
    }
  }

  String _getDayLabel(DateTime date, CalendarSystem system, int gregDay) {
    switch (system) {
      case CalendarSystem.gregorian:
        return '$gregDay';
      case CalendarSystem.kurdish:
        final kDate =
            CalendarConverter.gregorianToKurdish(date.year, date.month, gregDay);
        return _toArabicNumerals(kDate.day);
      case CalendarSystem.hijri:
        final hDate = CalendarConverter.gregorianToHijri(
            date.year, date.month, gregDay);
        return _toArabicNumerals(hDate.day);
    }
  }

  String _toArabicNumerals(int n) {
    const latin = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return n.toString().split('').map((c) {
      final idx = latin.indexOf(c);
      return idx >= 0 ? arabic[idx] : c;
    }).join();
  }
}

// ── Today's Events Section ─────────────────────────────────────────────────

class _TodaysEventsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final events = _getEventsForDate(selected);

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'بۆچوون',  // Events
                    style: AppTypography.textTheme.headlineSmall!.copyWith(
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                  Text(
                    '${selected.day}/${selected.month}/${selected.year}',
                    style: AppTypography.textTheme.bodySmall!.copyWith(
                      color: AppColors.inkLight,
                    ),
                  ),
                ],
              ),
            ),
            if (events.isEmpty)
              _EmptyEventsCard(isDark: isDark)
            else
              ...events.map((e) => _EventListTile(event: e, isDark: isDark)),
          ],
        ),
      ),
    );
  }

  List<CalendarEvent> _getEventsForDate(DateTime date) {
    return NotificationService.seedEventsForDemo.where((e) {
      return e.gregorianMonth == date.month && e.gregorianDay == date.day;
    }).toList();
  }
}

class _EventListTile extends StatelessWidget {
  final CalendarEvent event;
  final bool isDark;

  const _EventListTile({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalSurface : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.sunGold.withOpacity(0.08)
              : AppColors.creamBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Kurdish flag strip accent
              const FlagStripWidget(width: 5),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.titleKu,
                              style:
                                  AppTypography.textTheme.headlineSmall!.copyWith(
                                color: isDark ? Colors.white : AppColors.inkDark,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              event.titleEn,
                              style: AppTypography.textTheme.bodySmall!.copyWith(
                                color: AppColors.inkLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _EventTypeTag(event: event, isDark: isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Styled event type tag (replaces raw emoji chip)
class _EventTypeTag extends StatelessWidget {
  final CalendarEvent event;
  final bool isDark;

  const _EventTypeTag({required this.event, required this.isDark});

  Color _tagColor() {
    switch (event.eventType) {
      case EventType.holiday:   return AppColors.forestGreen;
      case EventType.tragedy:   return AppColors.kurdishRed;
      case EventType.milestone: return AppColors.sunGold;
      case EventType.cultural:  return AppColors.zagrosEarth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _tagColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        event.eventType.labelSorani,
        style: AppTypography.textTheme.labelSmall!.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _EmptyEventsCard extends StatelessWidget {
  final bool isDark;
  const _EmptyEventsCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalSurface : AppColors.creamSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppColors.sunGold.withOpacity(0.08)
              : AppColors.creamBorder,
        ),
      ),
      child: Row(
        children: [
          KurdishSunWidget(
            size: 24,
            color: AppColors.sunGold.withOpacity(0.4),
          ),
          const SizedBox(width: 12),
          Text(
            'بۆ ئەمڕۆ ئامادەکاری نییە',
            style: AppTypography.textTheme.bodyMedium!.copyWith(
              color: AppColors.inkLight,
            ),
          ),
        ],
      ),
    );
  }
}
