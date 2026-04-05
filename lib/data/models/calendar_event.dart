/// Kurdish Calendar App — Data Models

enum CalendarSystem {
  kurdish,
  gregorian,
  hijri;

  String get labelSorani {
    switch (this) {
      case CalendarSystem.kurdish:    return 'کوردی';
      case CalendarSystem.gregorian: return 'میلادی';
      case CalendarSystem.hijri:     return 'کۆچی';
    }
  }

  String get labelEnglish {
    switch (this) {
      case CalendarSystem.kurdish:    return 'Kurdish';
      case CalendarSystem.gregorian: return 'Gregorian';
      case CalendarSystem.hijri:     return 'Hijri';
    }
  }
}

enum EventType {
  holiday,
  tragedy,
  milestone,
  cultural;

  String get labelSorani {
    switch (this) {
      case EventType.holiday:   return 'جەژن';
      case EventType.tragedy:   return 'تراژیدی';
      case EventType.milestone: return 'دیكەی مێژوو';
      case EventType.cultural:  return 'کەلتووری';
    }
  }

  String get labelEnglish {
    switch (this) {
      case EventType.holiday:   return 'Holiday';
      case EventType.tragedy:   return 'Tragedy';
      case EventType.milestone: return 'Milestone';
      case EventType.cultural:  return 'Cultural';
    }
  }

  /// Culturally themed Unicode icon (replaces generic emojis)
  String get icon {
    switch (this) {
      case EventType.holiday:   return '☽';  // Crescent — Kurdish holiday symbol
      case EventType.tragedy:   return '✿';  // Memorial flower
      case EventType.milestone: return '✦';  // Star/milestone
      case EventType.cultural:  return '◆';  // Diamond — Kilim motif
    }
  }

  /// Keep emoji getter for backward compat but redirect to icon
  String get emoji => icon;
}

enum EventSignificance {
  local(1),
  national(2),
  international(3);

  final int value;
  const EventSignificance(this.value);
}

/// A pre-populated or user-created calendar event
class CalendarEvent {
  final int? id;
  final String titleKu;       // Sorani Kurdish
  final String? titleKmr;     // Kurmanji
  final String titleEn;
  final String? descriptionKu;
  final String? descriptionEn;

  // Primary storage: Gregorian (for indexed queries and cross-system display)
  final int gregorianMonth;
  final int gregorianDay;
  final int? gregorianYear; // null = recurring annually

  // Precomputed Kurdish equivalents
  final int kurdishMonth;
  final int kurdishDay;

  // Hijri equivalents
  final int? hijriMonth;
  final int? hijriDay;

  final EventType eventType;
  final bool isRecurring;
  final EventSignificance significance;
  final String? imageAsset;    // local asset path
  final String? sourceUrl;
  final DateTime? createdAt;

  const CalendarEvent({
    this.id,
    required this.titleKu,
    this.titleKmr,
    required this.titleEn,
    this.descriptionKu,
    this.descriptionEn,
    required this.gregorianMonth,
    required this.gregorianDay,
    this.gregorianYear,
    required this.kurdishMonth,
    required this.kurdishDay,
    this.hijriMonth,
    this.hijriDay,
    required this.eventType,
    this.isRecurring = true,
    this.significance = EventSignificance.national,
    this.imageAsset,
    this.sourceUrl,
    this.createdAt,
  });

  String titleForLocale(String locale) {
    switch (locale) {
      case 'ckb': return titleKu;
      case 'kmr': return titleKmr ?? titleEn;
      default:    return titleEn;
    }
  }

  String? descriptionForLocale(String locale) {
    switch (locale) {
      case 'ckb': return descriptionKu ?? descriptionEn;
      default:    return descriptionEn ?? descriptionKu;
    }
  }

  CalendarEvent copyWith({
    int? id,
    String? titleKu,
    String? titleKmr,
    String? titleEn,
    String? descriptionKu,
    String? descriptionEn,
    int? gregorianMonth,
    int? gregorianDay,
    int? gregorianYear,
    int? kurdishMonth,
    int? kurdishDay,
    int? hijriMonth,
    int? hijriDay,
    EventType? eventType,
    bool? isRecurring,
    EventSignificance? significance,
    String? imageAsset,
    String? sourceUrl,
    DateTime? createdAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      titleKu: titleKu ?? this.titleKu,
      titleKmr: titleKmr ?? this.titleKmr,
      titleEn: titleEn ?? this.titleEn,
      descriptionKu: descriptionKu ?? this.descriptionKu,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      gregorianMonth: gregorianMonth ?? this.gregorianMonth,
      gregorianDay: gregorianDay ?? this.gregorianDay,
      gregorianYear: gregorianYear ?? this.gregorianYear,
      kurdishMonth: kurdishMonth ?? this.kurdishMonth,
      kurdishDay: kurdishDay ?? this.kurdishDay,
      hijriMonth: hijriMonth ?? this.hijriMonth,
      hijriDay: hijriDay ?? this.hijriDay,
      eventType: eventType ?? this.eventType,
      isRecurring: isRecurring ?? this.isRecurring,
      significance: significance ?? this.significance,
      imageAsset: imageAsset ?? this.imageAsset,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User-created personal note for a specific date
class UserNote {
  final int? id;
  final String title;
  final String? body;
  final DateTime date;
  final String? reminderTime;  // "HH:mm"
  final String colorHex;
  final DateTime createdAt;

  const UserNote({
    this.id,
    required this.title,
    this.body,
    required this.date,
    this.reminderTime,
    this.colorHex = '#FFD700',
    required this.createdAt,
  });
}

/// Notification preferences
class NotificationPrefs {
  final bool enabled;
  final bool holidays;
  final bool tragedies;
  final bool milestones;
  final bool cultural;
  final int notifHour;    // 0-23
  final int notifMinute;  // 0-59

  const NotificationPrefs({
    this.enabled = false,
    this.holidays = false,
    this.tragedies = false,
    this.milestones = false,
    this.cultural = false,
    this.notifHour = 9,
    this.notifMinute = 0,
  });

  bool shouldNotifyFor(EventType type) {
    if (!enabled) return false;
    switch (type) {
      case EventType.holiday:   return holidays;
      case EventType.tragedy:   return tragedies;
      case EventType.milestone: return milestones;
      case EventType.cultural:  return cultural;
    }
  }

  NotificationPrefs copyWith({
    bool? enabled,
    bool? holidays,
    bool? tragedies,
    bool? milestones,
    bool? cultural,
    int? notifHour,
    int? notifMinute,
  }) {
    return NotificationPrefs(
      enabled: enabled ?? this.enabled,
      holidays: holidays ?? this.holidays,
      tragedies: tragedies ?? this.tragedies,
      milestones: milestones ?? this.milestones,
      cultural: cultural ?? this.cultural,
      notifHour: notifHour ?? this.notifHour,
      notifMinute: notifMinute ?? this.notifMinute,
    );
  }
}
