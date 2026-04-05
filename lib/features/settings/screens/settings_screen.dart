import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/kurdish_painters.dart';
import '../../../data/models/calendar_event.dart';
import '../../../services/notification_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  NotificationPrefs _prefs = const NotificationPrefs();
  bool _useKurdishNumerals = true;
  CalendarSystem _defaultCalendar = CalendarSystem.kurdish;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await NotificationService.instance.loadPrefs();
    if (!mounted) return;
    setState(() => _prefs = prefs);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: isDark ? AppColors.charcoalBg : AppColors.forestGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.headerGradientDark
                          : AppColors.headerGradientLight,
                    ),
                  ),
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
              'ڕێکخستنەکان',
              style: AppTypography.textTheme.headlineMedium!
                  .copyWith(color: Colors.white),
            ),
            centerTitle: false,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Calendar Section ────────────────────────────────────
                _SectionHeader(
                  title: 'ساڵنامە',
                  subtitle: 'Calendar Settings',
                  icon: '◆',
                  iconColor: AppColors.sunGold,
                  isDark: isDark,
                ),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    _DropdownTile(
                      label: 'ساڵنامەی بنەڕەت',
                      sublabel: 'Default Calendar System',
                      value: _defaultCalendar,
                      items: CalendarSystem.values,
                      labelBuilder: (s) => '${s.labelSorani} / ${s.labelEnglish}',
                      onChanged: (v) => setState(() => _defaultCalendar = v!),
                      isDark: isDark,
                    ),
                    _Divider(isDark: isDark),
                    SwitchListTile(
                      title: Text(
                        'ژمارەی کوردی',
                        style: AppTypography.textTheme.bodyMedium!.copyWith(
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      subtitle: Text(
                        'Kurdish Numerals (١٢٣)',
                        style: AppTypography.textTheme.bodySmall!
                            .copyWith(color: AppColors.inkLight),
                      ),
                      value: _useKurdishNumerals,
                      activeColor: AppColors.sunGold,
                      onChanged: (v) => setState(() => _useKurdishNumerals = v),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Notification Section ────────────────────────────────
                _SectionHeader(
                  title: 'ئاگادارکردنەوە',
                  subtitle: 'Notifications',
                  icon: '✦',
                  iconColor: AppColors.forestGreen,
                  isDark: isDark,
                ),
                _SettingsCard(
                  isDark: isDark,
                  children: [
                    SwitchListTile(
                      title: Text(
                        'چالاک بکە',
                        style: AppTypography.textTheme.bodyMedium!.copyWith(
                          color: isDark ? Colors.white : AppColors.inkDark,
                        ),
                      ),
                      subtitle: Text(
                        'Enable "On This Day" alerts',
                        style: AppTypography.textTheme.bodySmall!
                            .copyWith(color: AppColors.inkLight),
                      ),
                      value: _prefs.enabled,
                      activeColor: AppColors.sunGold,
                      onChanged: (v) =>
                          setState(() => _prefs = _prefs.copyWith(enabled: v)),
                    ),
                    if (_prefs.enabled) ...[
                      _Divider(isDark: isDark),
                      _TimePicker(
                        hour: _prefs.notifHour,
                        minute: _prefs.notifMinute,
                        isDark: isDark,
                        onChanged: (h, m) => setState(
                          () => _prefs = _prefs.copyWith(notifHour: h, notifMinute: m),
                        ),
                      ),
                      _Divider(isDark: isDark),
                      _NotifToggle(
                        icon: '☽',
                        iconColor: AppColors.forestGreen,
                        labelKu: 'جەژنەکان',
                        labelEn: 'Holidays',
                        value: _prefs.holidays,
                        accentColor: AppColors.forestGreen,
                        isDark: isDark,
                        onChanged: (v) =>
                            setState(() => _prefs = _prefs.copyWith(holidays: v)),
                      ),
                      _NotifToggle(
                        icon: '✿',
                        iconColor: AppColors.kurdishRed,
                        labelKu: 'تراژیدیەکان',
                        labelEn: 'Tragic Events',
                        value: _prefs.tragedies,
                        accentColor: AppColors.kurdishRed,
                        isDark: isDark,
                        onChanged: (v) =>
                            setState(() => _prefs = _prefs.copyWith(tragedies: v)),
                      ),
                      _NotifToggle(
                        icon: '✦',
                        iconColor: AppColors.sunGoldDeep,
                        labelKu: 'ئەدیبان و شاعیرانە',
                        labelEn: 'Poets & Writers',
                        value: _prefs.milestones,
                        accentColor: AppColors.sunGoldDeep,
                        isDark: isDark,
                        onChanged: (v) =>
                            setState(() => _prefs = _prefs.copyWith(milestones: v)),
                      ),
                      _NotifToggle(
                        icon: '◆',
                        iconColor: AppColors.zagrosEarth,
                        labelKu: 'کەلتووری',
                        labelEn: 'Cultural Events',
                        value: _prefs.cultural,
                        accentColor: AppColors.zagrosEarth,
                        isDark: isDark,
                        onChanged: (v) =>
                            setState(() => _prefs = _prefs.copyWith(cultural: v)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 24),

                // ── Save Button ─────────────────────────────────────────
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kurdishRed,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.kurdishRed.withOpacity(0.3),
                    ),
                    child: Text(
                      'پاشەکەوتکردن',
                      style: AppTypography.textTheme.labelLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // ── About ────────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      KurdishSunWidget(
                        size: 32,
                        color: AppColors.sunGold.withOpacity(0.3),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'ساڵنامەی کوردستان',
                        style: AppTypography.textTheme.headlineSmall!
                            .copyWith(color: isDark ? Colors.white38 : AppColors.inkMedium),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kurdistan Calendar v1.0.0',
                        style: AppTypography.textTheme.bodySmall!
                            .copyWith(color: AppColors.inkLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await NotificationService.instance.savePrefs(_prefs);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('ڕێکخستنەکان پاشەکەوتکران ✓'),
          backgroundColor: AppColors.forestGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;
  final Color iconColor;
  final bool isDark;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                icon,
                style: TextStyle(fontSize: 14, color: iconColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.textTheme.headlineSmall!.copyWith(
                  color: isDark ? Colors.white : AppColors.inkDark,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 22),
            child: Text(
              subtitle,
              style: AppTypography.textTheme.bodySmall!
                  .copyWith(color: AppColors.inkLight),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsCard({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: isDark
          ? Colors.white.withOpacity(0.06)
          : AppColors.creamBorder.withOpacity(0.6),
      indent: 16,
      endIndent: 16,
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final String icon;
  final Color iconColor;
  final String labelKu;
  final String labelEn;
  final bool value;
  final Color accentColor;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _NotifToggle({
    required this.icon,
    required this.iconColor,
    required this.labelKu,
    required this.labelEn,
    required this.value,
    required this.accentColor,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            icon,
            style: TextStyle(fontSize: 16, color: iconColor),
          ),
        ),
      ),
      title: Text(
        labelKu,
        style: AppTypography.textTheme.bodyMedium!.copyWith(
          color: isDark ? Colors.white : AppColors.inkDark,
        ),
      ),
      subtitle: Text(
        labelEn,
        style: AppTypography.textTheme.bodySmall!.copyWith(color: AppColors.inkLight),
      ),
      value: value,
      activeColor: accentColor,
      onChanged: onChanged,
    );
  }
}

class _TimePicker extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isDark;
  final void Function(int hour, int minute) onChanged;

  const _TimePicker({
    required this.hour,
    required this.minute,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    return ListTile(
      leading: const Icon(Icons.access_time_rounded, color: AppColors.sunGold),
      title: Text(
        'کاتی ئاگادارکردنەوە',
        style: AppTypography.textTheme.bodyMedium!.copyWith(
          color: isDark ? Colors.white : AppColors.inkDark,
        ),
      ),
      subtitle: Text(
        'Notification Time',
        style: AppTypography.textTheme.bodySmall!.copyWith(color: AppColors.inkLight),
      ),
      trailing: GestureDetector(
        onTap: () async {
          final picked = await showTimePicker(
            context: context,
            initialTime: TimeOfDay(hour: hour, minute: minute),
          );
          if (picked != null) {
            onChanged(picked.hour, picked.minute);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.sunGold.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.sunGold.withOpacity(0.3)),
          ),
          child: Text(
            timeStr,
            style: AppTypography.textTheme.labelLarge!.copyWith(
              color: AppColors.sunGoldDeep,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final String label;
  final String sublabel;
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final ValueChanged<T?> onChanged;
  final bool isDark;

  const _DropdownTile({
    required this.label,
    required this.sublabel,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        label,
        style: AppTypography.textTheme.bodyMedium!.copyWith(
          color: isDark ? Colors.white : AppColors.inkDark,
        ),
      ),
      subtitle: Text(
        sublabel,
        style: AppTypography.textTheme.bodySmall!.copyWith(
          color: AppColors.inkLight,
        ),
      ),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        dropdownColor:
            isDark ? AppColors.charcoalElevated : AppColors.creamSurface,
        style: AppTypography.textTheme.bodyMedium!.copyWith(
          color: isDark ? Colors.white : AppColors.inkDark,
        ),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelBuilder(item)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
