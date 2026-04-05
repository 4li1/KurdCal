// Web stub — flutter_local_notifications is not available on web.
// All methods are silent no-ops so the app compiles and runs cleanly.

import '../data/models/calendar_event.dart';

Future<void> initialize() async {}
Future<bool> requestPermission() async => false;
Future<void> scheduleOnThisDayNotifications({
  int daysAhead = 30,
  List<CalendarEvent>? events,
}) async {}
Future<void> savePrefs(NotificationPrefs prefs) async {}
Future<NotificationPrefs> loadPrefs() async => const NotificationPrefs();
