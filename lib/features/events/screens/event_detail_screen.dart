import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/kurdish_painters.dart';
import '../../../core/utils/calendar_converter.dart';
import '../../../data/models/calendar_event.dart';
import '../../../services/notification_service.dart';

class EventDetailScreen extends ConsumerWidget {
  final CalendarEvent event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _EventHeroAppBar(event: event),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event type chip
                  _EventTypeChip(event: event),
                  const SizedBox(height: 16),

                  // Kurdish title
                  Text(
                    event.titleKu,
                    style: AppTypography.textTheme.headlineLarge!.copyWith(
                      color: isDark ? Colors.white : AppColors.inkDark,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // English title
                  Text(
                    event.titleEn,
                    style: AppTypography.textTheme.headlineMedium!.copyWith(
                      color: AppColors.inkMedium,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Three-calendar date row
                  _DatePillsRow(event: event),
                  const SizedBox(height: 24),

                  // Kilim-style decorative divider
                  _KilimDivider(isDark: isDark),
                  const SizedBox(height: 24),

                  // Description
                  if (event.descriptionEn != null ||
                      event.descriptionKu != null) ...[
                    _DescriptionSection(event: event, isDark: isDark),
                    const SizedBox(height: 24),
                  ],

                  // "Why This Matters" pull-quote
                  _SignificancePullQuote(event: event, isDark: isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _DetailBottomBar(event: event),
    );
  }
}

// ── Hero App Bar ─────────────────────────────────────────────────────────

class _EventHeroAppBar extends StatelessWidget {
  final CalendarEvent event;
  const _EventHeroAppBar({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: _headerColor(event.eventType),
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _headerColor(event.eventType),
                    _headerColor(event.eventType).withOpacity(0.7),
                  ],
                ),
              ),
            ),
            // Kilim border at top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: KilimBorderWidget(
                height: 40,
                color: AppColors.sunGold,
                opacity: 0.06,
              ),
            ),
            if (event.imageAsset != null)
              Hero(
                tag: 'event_${event.id}',
                child: Image.asset(
                  event.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            // Bottom gradient
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            // Sun watermark instead of emoji
            Positioned(
              right: 20,
              bottom: 20,
              child: Opacity(
                opacity: 0.15,
                child: KurdishSunWidget(
                  size: 80,
                  color: AppColors.sunGold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _headerColor(EventType type) {
    switch (type) {
      case EventType.holiday:   return AppColors.forestGreen;
      case EventType.tragedy:   return AppColors.kurdishRed;
      case EventType.milestone: return const Color(0xFF1A3A5C);
      case EventType.cultural:  return AppColors.zagrosEarth;
    }
  }
}

// ── Event Type Chip ───────────────────────────────────────────────────────

class _EventTypeChip extends StatelessWidget {
  final CalendarEvent event;
  const _EventTypeChip({required this.event});

  Color _chipColor(EventType type) {
    switch (type) {
      case EventType.holiday:   return AppColors.eventHoliday;
      case EventType.tragedy:   return AppColors.eventTragedy;
      case EventType.milestone: return AppColors.eventMilestone;
      case EventType.cultural:  return AppColors.eventCultural;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _chipColor(event.eventType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cultural icon instead of emoji
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(
              child: Text(
                event.eventType.icon,
                style: TextStyle(fontSize: 11, color: color),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            event.eventType.labelSorani,
            style: AppTypography.textTheme.labelLarge!.copyWith(
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '· ${event.eventType.labelEnglish}',
            style: AppTypography.textTheme.labelMedium!.copyWith(
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Three-Calendar Date Pills ─────────────────────────────────────────────

class _DatePillsRow extends StatelessWidget {
  final CalendarEvent event;
  const _DatePillsRow({required this.event});

  @override
  Widget build(BuildContext context) {
    final gregDate = DateTime(
      event.gregorianYear ?? DateTime.now().year,
      event.gregorianMonth,
      event.gregorianDay,
    );
    final hijri = CalendarConverter.gregorianToHijri(
      gregDate.year, gregDate.month, gregDate.day);

    final kurdishMonth = [
      'خاکەلێوە', 'گوڵان', 'جۆزەردان', 'پووشپەڕ', 'گەلاوێژ', 'خەرمانان',
      'ڕەزبەر', 'خەزەڵوەر', 'سەرماوەز', 'بەفرانبار', 'ڕێبەندان', 'ڕەشەمێ',
    ][event.kurdishMonth - 1];

    return Row(
      children: [
        Expanded(
          child: _DatePill(
            system: 'کوردی',
            date: '${event.kurdishDay} $kurdishMonth',
            color: AppColors.forestGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DatePill(
            system: 'میلادی',
            date: '${event.gregorianDay}/${event.gregorianMonth}',
            color: AppColors.sunGoldDeep,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DatePill(
            system: 'کۆچی',
            date: '${hijri.day}/${hijri.month}/${hijri.year}',
            color: AppColors.kurdishRed,
          ),
        ),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  final String system;
  final String date;
  final Color color;

  const _DatePill({
    required this.system,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            date,
            style: AppTypography.textTheme.bodyMedium!.copyWith(
              color: isDark ? Colors.white : AppColors.inkDark,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            system,
            style: AppTypography.textTheme.labelSmall!.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Kilim-style Decorative Divider ────────────────────────────────────────

class _KilimDivider extends StatelessWidget {
  final bool isDark;
  const _KilimDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        KilimBorderWidget(
          height: 30,
          color: isDark ? AppColors.sunGold : AppColors.zagrosEarth,
          opacity: isDark ? 0.12 : 0.15,
        ),
      ],
    );
  }
}

// ── Description ───────────────────────────────────────────────────────────

class _DescriptionSection extends StatelessWidget {
  final CalendarEvent event;
  final bool isDark;

  const _DescriptionSection({required this.event, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.descriptionKu != null) ...[
          Text(
            event.descriptionKu!,
            style: AppTypography.textTheme.bodyLarge!.copyWith(
              color: isDark ? Colors.white70 : AppColors.inkDark,
              height: 1.8,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 12),
        ],
        if (event.descriptionEn != null)
          Text(
            event.descriptionEn!,
            style: AppTypography.textTheme.bodyLarge!.copyWith(
              color: isDark
                  ? Colors.white60
                  : AppColors.inkMedium,
              height: 1.7,
            ),
            textDirection: TextDirection.ltr,
          ),
      ],
    );
  }
}

// ── Pull-Quote Significance Card ──────────────────────────────────────────

class _SignificancePullQuote extends StatelessWidget {
  final CalendarEvent event;
  final bool isDark;

  const _SignificancePullQuote({required this.event, required this.isDark});

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.07),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
          topLeft: Radius.circular(4),
          bottomLeft: Radius.circular(4),
        ),
        border: Border(
          right: BorderSide(color: accent, width: 6),
        ),
      ),
      child: Row(
        children: [
          Text(
            '❝',
            style: TextStyle(fontSize: 32, color: AppColors.sunGold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              event.significance == EventSignificance.international
                  ? 'ئەمە ڕووداوێکی جیهانیە کە کاریگەری مەزنی لەسەر کوردستان هەبووە'
                  : 'ئەمە بەشێکی گرنگی مێژووی کوردەکانە',
              style: AppTypography.textTheme.bodyMedium!.copyWith(
                color: isDark ? Colors.white70 : AppColors.inkMedium,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bottom Action Bar ─────────────────────────────────────────────────────

class _DetailBottomBar extends StatelessWidget {
  final CalendarEvent event;
  const _DetailBottomBar({required this.event});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoalSurface : AppColors.creamSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.sunGold.withOpacity(0.1)
                : AppColors.creamBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share_outlined),
              label: const Text('هاوبەشی بکە'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: isDark
                      ? AppColors.sunGold.withOpacity(0.3)
                      : AppColors.creamBorder,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
              label: const Text('ئاگادارکردنەوە'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sunGold,
                foregroundColor: AppColors.inkDark,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
