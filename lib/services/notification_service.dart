import 'package:flutter/foundation.dart';
import '../data/models/calendar_event.dart';

// flutter_local_notifications only works on mobile/desktop, not web.
// We conditionally import it to keep the web build clean.
import 'notification_service_mobile.dart'
    if (dart.library.html) 'notification_service_stub.dart' as _impl;

/// Public façade — callers always use this class.
/// On mobile/desktop it delegates to flutter_local_notifications.
/// On web it's a silent no-op.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  Future<void> initialize() async {
    if (kIsWeb) return;
    await _impl.initialize();
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    return _impl.requestPermission();
  }

  Future<void> scheduleOnThisDayNotifications({
    int daysAhead = 30,
    List<CalendarEvent>? events,
  }) async {
    if (kIsWeb) return;
    await _impl.scheduleOnThisDayNotifications(
      daysAhead: daysAhead,
      events: events ?? seedEventsForDemo,
    );
  }

  Future<void> savePrefs(NotificationPrefs prefs) async {
    if (kIsWeb) return;
    await _impl.savePrefs(prefs);
  }

  Future<NotificationPrefs> loadPrefs() async {
    if (kIsWeb) return const NotificationPrefs();
    return _impl.loadPrefs();
  }

  // Seed events are kept public so screens can reference them without a DB.
  static final seedEventsForDemo = <CalendarEvent>[
    const CalendarEvent(
      id: 1,
      titleKu: 'نەورۆز',
      titleEn: 'Newroz — Kurdish New Year',
      gregorianMonth: 3,
      gregorianDay: 21,
      kurdishMonth: 1,
      kurdishDay: 1,
      eventType: EventType.holiday,
      significance: EventSignificance.international,
      descriptionKu:
          'نەورۆز ساڵی نوێی کوردییە کە لە ڕۆژی یەکەمی بەهاردا دەبێتەوە.',
      descriptionEn:
          'Newroz (New Day) is the Kurdish New Year celebration marking the '
          'first day of spring. It symbolises rebirth, freedom, and the victory '
          'of light over darkness. The legend of Kawa the Blacksmith defeating '
          'the tyrant Zuhak is central to this celebration.',
    ),
    const CalendarEvent(
      id: 2,
      titleKu: 'تراژیدیای هەڵەبجە',
      titleEn: 'Halabja Chemical Attack',
      gregorianMonth: 3,
      gregorianDay: 16,
      gregorianYear: 1988,
      kurdishMonth: 12,
      kurdishDay: 26,
      eventType: EventType.tragedy,
      significance: EventSignificance.international,
      descriptionKu:
          'لە ١٦ی مارسی ١٩٨٨دا، ڕژێمی بەعسی عێراق کیمیای کوژەر بەرەو شاری '
          'هەڵەبجەی کوردستان بەکارھێنا.',
      descriptionEn:
          'On March 16, 1988, the Iraqi Ba\'athist regime under Saddam Hussein '
          'carried out a chemical weapons attack on the Kurdish town of Halabja, '
          'killing between 3,200 and 5,000 civilians. It remains the largest '
          'chemical weapons attack against a civilian population in history.',
    ),
    const CalendarEvent(
      id: 3,
      titleKu: 'کۆماری مەهاباد',
      titleEn: 'Republic of Mahabad Founded',
      gregorianMonth: 1,
      gregorianDay: 22,
      gregorianYear: 1946,
      kurdishMonth: 11,
      kurdishDay: 2,
      eventType: EventType.milestone,
      significance: EventSignificance.international,
      descriptionKu: 'کۆماری مەهاباد لە ٢٢ی کانوونی دووەمی ١٩٤٦ بە سەرۆکایەتیی '
          'قازی محەمەد دامەزرا.',
      descriptionEn:
          'The Republic of Mahabad was proclaimed on January 22, 1946 in north-'
          'western Iran. Led by Qazi Muhammad, it was one of the first modern '
          'Kurdish states. Though it lasted only 11 months, it remains a powerful '
          'symbol of Kurdish self-determination.',
    ),
    const CalendarEvent(
      id: 4,
      titleKu: 'ڕاپەڕین ١٩٩١',
      titleEn: 'The 1991 Raperin Uprising',
      gregorianMonth: 3,
      gregorianDay: 4,
      gregorianYear: 1991,
      kurdishMonth: 12,
      kurdishDay: 14,
      eventType: EventType.milestone,
      significance: EventSignificance.international,
      descriptionKu:
          'ڕاپەڕینی ماوەز ١٩٩١ شۆڕشێکی گەلیی کوردی بوو دژی ڕژێمی بەعسی عێراق.',
      descriptionEn:
          'The Raperin (Uprising) of March 1991 was a mass Kurdish revolt against '
          'the Iraqi Ba\'athist government following the Gulf War. Though initially '
          'successful, it led to a massive refugee exodus and ultimately resulted in '
          'de-facto Kurdish autonomy in northern Iraq.',
    ),
    const CalendarEvent(
      id: 5,
      titleKu: 'ڕۆژی ئاڵای کوردستان',
      titleEn: 'Kurdistan Flag Day',
      gregorianMonth: 12,
      gregorianDay: 17,
      kurdishMonth: 9,
      kurdishDay: 26,
      eventType: EventType.holiday,
      significance: EventSignificance.national,
      descriptionKu:
          'ڕۆژی ئاڵای کوردستان بیرەوەرییە لە پەسەندکردنی ئاڵای کوردستان.',
      descriptionEn:
          'Kurdistan Flag Day commemorates the adoption of the Kurdistan flag '
          'with its distinctive red, white, and green stripes and the golden '
          '21-rayed sun at its centre — a symbol of Newroz and life.',
    ),
    const CalendarEvent(
      id: 6,
      titleKu: 'ڕۆژی جلوبەرگی کوردی',
      titleEn: 'Kurdish Traditional Clothes Day',
      gregorianMonth: 5,
      gregorianDay: 28,
      kurdishMonth: 2,
      kurdishDay: 7,
      eventType: EventType.cultural,
      significance: EventSignificance.national,
      descriptionEn:
          'Celebrated annually, this day encourages Kurds worldwide to wear their '
          'traditional clothing as a symbol of cultural pride and identity.',
    ),
    const CalendarEvent(
      id: 7,
      titleKu: 'بنیادنانی ئەنفال',
      titleEn: 'Anfal Genocide Campaign Begins',
      gregorianMonth: 2,
      gregorianDay: 23,
      gregorianYear: 1988,
      kurdishMonth: 12,
      kurdishDay: 3,
      eventType: EventType.tragedy,
      significance: EventSignificance.international,
      descriptionEn:
          'The Anfal genocide was a systematic campaign of extermination carried '
          'out by the Iraqi Ba\'athist government against Kurdish people. Between '
          '50,000 and 182,000 Kurds perished.',
    ),
  ];
}
