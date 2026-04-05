import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/kurdish_painters.dart';
import '../../../core/theme/kurdish_theme_extension.dart';
import '../../../data/models/calendar_event.dart';
import '../../../services/notification_service.dart';
import '../../events/screens/event_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
    final events = List<CalendarEvent>.from(NotificationService.seedEventsForDemo)
      ..sort((a, b) => a.gregorianMonth.compareTo(b.gregorianMonth));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: scheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [headerStart, headerEnd],
                      ),
                    ),
                  ),
                  // Kilim border overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: KilimBorderWidget(
                      height: 35,
                      color: AppColors.sunGold,
                      opacity: isDark ? 0.05 : 0.08,
                      flipVertical: true,
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              'مێژووی کوردستان',
              style: AppTypography.textTheme.headlineMedium!
                  .copyWith(color: ext?.headerText ?? Colors.white),
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index.isOdd) return const SizedBox(height: 12);
                  final eventIndex = index ~/ 2;
                  if (eventIndex >= events.length) return null;
                  return _HistoryEventCard(
                    event: events[eventIndex],
                    isDark: isDark,
                  );
                },
                childCount: events.length * 2 - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryEventCard extends StatelessWidget {
  final CalendarEvent event;
  final bool isDark;

  const _HistoryEventCard({required this.event, required this.isDark});

  Color _accentColor() {
    switch (event.eventType) {
      case EventType.holiday:   return AppColors.forestGreen;
      case EventType.tragedy:   return AppColors.kurdishRed;
      case EventType.milestone: return AppColors.sunGoldDeep;
      case EventType.cultural:  return AppColors.zagrosEarth;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.charcoalSurface : AppColors.creamSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppColors.sunGold.withOpacity(0.08)
                : AppColors.creamBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Kurdish flag color strip
                const FlagStripWidget(width: 5),
                // Left date block
                Container(
                  width: 60,
                  color: accent.withOpacity(0.08),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${event.gregorianDay}',
                        style: AppTypography.textTheme.headlineLarge!.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        _monthAbbrev(event.gregorianMonth),
                        style: AppTypography.textTheme.labelSmall!.copyWith(
                          color: accent.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                // Right content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Cultural icon indicator
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: accent.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  event.eventType.icon,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: accent,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                event.titleKu,
                                style:
                                    AppTypography.textTheme.headlineSmall!.copyWith(
                                  color: isDark ? Colors.white : AppColors.inkDark,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          event.titleEn,
                          style: AppTypography.textTheme.bodySmall!.copyWith(
                            color: AppColors.inkLight,
                          ),
                        ),
                        if (event.gregorianYear != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${event.gregorianYear}',
                              style: AppTypography.textTheme.labelSmall!
                                  .copyWith(color: accent),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_left_rounded,
                  color: isDark ? Colors.white24 : AppColors.inkLight,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _monthAbbrev(int month) {
    const abbrevs = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return month >= 1 && month <= 12 ? abbrevs[month - 1] : '?';
  }
}
