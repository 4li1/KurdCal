// Mobile/Desktop implementation of notification helpers.
// Imported only on non-web platforms via conditional import in notification_service.dart.

import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import '../data/models/calendar_event.dart';

final _plugin = FlutterLocalNotificationsPlugin();
bool _initialized = false;

const _channelId = 'kurdish_history_channel';
const _channelName = 'Kurdish History Alerts';
const _channelDesc = 'Daily notifications about Kurdish historical events';
const _baseId = 1000;

const _keyEnabled = 'notif_enabled';
const _keyHolidays = 'notif_holidays';
const _keyTragedies = 'notif_tragedies';
const _keyMilestones = 'notif_milestones';
const _keyCultural = 'notif_cultural';
const _keyHour = 'notif_hour';
const _keyMinute = 'notif_minute';

Future<void> initialize() async {
  if (_initialized) return;
  if (Platform.isWindows) return; // Windows not supported by this plugin setup

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const iosInit = DarwinInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  const linuxInit = LinuxInitializationSettings(defaultActionName: 'Open');

  await _plugin.initialize(
    const InitializationSettings(
      android: androidInit,
      iOS: iosInit,
      linux: linuxInit,
    ),
  );

  if (Platform.isAndroid) {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  _initialized = true;
}

Future<bool> requestPermission() async {
  if (Platform.isIOS) {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    return result ?? false;
  }
  if (Platform.isAndroid) {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return result ?? false;
  }
  return true;
}

Future<void> scheduleOnThisDayNotifications({
  int daysAhead = 30,
  List<CalendarEvent>? events,
}) async {
  if (!_initialized) await initialize();
  if (Platform.isWindows) return; // Windows not supported
  final prefs = await _getPrefs();
  if (!prefs.enabled) return;

  // Cancel previous batch
  for (int i = _baseId; i < _baseId + 500; i++) {
    await _plugin.cancel(i);
  }

  int id = _baseId;
  final today = DateTime.now();

  for (int offset = 0; offset < daysAhead; offset++) {
    final target = today.add(Duration(days: offset));
    final matching = (events ?? []).where((e) {
      return e.gregorianMonth == target.month &&
          e.gregorianDay == target.day &&
          (e.gregorianYear == null || e.gregorianYear == target.year);
    });

    for (final event in matching) {
      if (!prefs.shouldNotifyFor(event.eventType)) continue;
      final scheduled = DateTime(
        target.year, target.month, target.day, prefs.notifHour, prefs.notifMinute,
      );
      if (scheduled.isBefore(DateTime.now())) continue;

      await _plugin.zonedSchedule(
        id++,
        '${event.eventType.emoji} ${event.titleKu}',
        event.titleEn,
        tz.TZDateTime.from(scheduled, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId, _channelName,
            channelDescription: _channelDesc,
            importance: Importance.high,
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: 'event:${event.id}',
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}

Future<void> savePrefs(NotificationPrefs prefs) async {
  final sp = await SharedPreferences.getInstance();
  await Future.wait([
    sp.setBool(_keyEnabled, prefs.enabled),
    sp.setBool(_keyHolidays, prefs.holidays),
    sp.setBool(_keyTragedies, prefs.tragedies),
    sp.setBool(_keyMilestones, prefs.milestones),
    sp.setBool(_keyCultural, prefs.cultural),
    sp.setInt(_keyHour, prefs.notifHour),
    sp.setInt(_keyMinute, prefs.notifMinute),
  ]);
}

Future<NotificationPrefs> _getPrefs() async {
  final sp = await SharedPreferences.getInstance();
  return NotificationPrefs(
    enabled: sp.getBool(_keyEnabled) ?? true,
    holidays: sp.getBool(_keyHolidays) ?? true,
    tragedies: sp.getBool(_keyTragedies) ?? true,
    milestones: sp.getBool(_keyMilestones) ?? true,
    cultural: sp.getBool(_keyCultural) ?? true,
    notifHour: sp.getInt(_keyHour) ?? 9,
    notifMinute: sp.getInt(_keyMinute) ?? 0,
  );
}
