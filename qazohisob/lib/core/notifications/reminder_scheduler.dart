import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';

/// Schedules the optional daily reminders.
///
/// A reminder is only a prompt: nothing is ever recorded automatically when
/// a notification fires. The user always marks completion manually.
abstract interface class ReminderScheduler {
  /// Asks iOS for permission. Returns true if notifications are allowed.
  Future<bool> requestPermission();

  /// Cancels and re-creates reminders to match [settings].
  Future<void> apply(Setting settings);
}

const int prayerReminderId = 101;
const int fastingReminderId = 102;

/// Next time (today or tomorrow) the clock shows [minutes] after midnight.
DateTime nextDailyOccurrence(int minutes, DateTime now) {
  var next = DateTime(
    now.year,
    now.month,
    now.day,
    minutes ~/ 60,
    minutes % 60,
  );
  if (!next.isAfter(now)) {
    next = DateTime(
      now.year,
      now.month,
      now.day + 1,
      minutes ~/ 60,
      minutes % 60,
    );
  }
  return next;
}

class LocalReminderScheduler implements ReminderScheduler {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Vaqt mintaqasini aniqlab bo‘lmadi: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios == null) return false;
    return await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  @override
  Future<void> apply(Setting settings) async {
    await init();
    await _plugin.cancel(id: prayerReminderId);
    await _plugin.cancel(id: fastingReminderId);
    if (!settings.notificationsEnabled) return;
    if (settings.prayerReminderEnabled) {
      await _schedule(
        id: prayerReminderId,
        minutes: settings.prayerReminderTime,
        title: 'Qazo namoz',
        body:
            'Bugun qazo namozlaringizdan ado qilishni unutmang. '
            'Ado qilganingizni ilovada o‘zingiz belgilang.',
      );
    }
    if (settings.fastingReminderEnabled) {
      await _schedule(
        id: fastingReminderId,
        minutes: settings.fastingReminderTime,
        title: 'Qazo ro‘za',
        body:
            'Qazo ro‘zangizni rejalashtirishni unutmang. '
            'Tutgan kuningizni ilovada o‘zingiz belgilang.',
      );
    }
  }

  Future<void> _schedule({
    required int id,
    required int minutes,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: at,
      notificationDetails: const NotificationDetails(
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

/// Used in tests and on platforms without notification support.
class NoopReminderScheduler implements ReminderScheduler {
  Setting? lastApplied;
  bool permission = true;

  @override
  Future<void> apply(Setting settings) async => lastApplied = settings;

  @override
  Future<bool> requestPermission() async => permission;
}
