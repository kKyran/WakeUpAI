import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/wake_alarm.dart';

typedef AlarmTapHandler = void Function(String? payload);

class AlarmScheduler {
  AlarmScheduler({
    FlutterLocalNotificationsPlugin? notifications,
  }) : _notifications = notifications ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _notifications;
  var _ready = false;

  Future<void> initialize({AlarmTapHandler? onTap}) async {
    tzdata.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        onTap?.call(response.payload);
      },
    );

    _ready = true;
  }

  Future<void> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    final iosImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosImplementation?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> scheduleDaily(WakeAlarm alarm) async {
    if (!_ready) {
      return;
    }

    final scheduled = tz.TZDateTime.from(
      alarm.time.nextOccurrence(),
      tz.local,
    );

    await _notifications.zonedSchedule(
      _notificationId(alarm.id),
      'WakeUp AI',
      '${alarm.task.title} орындау уақыты келді',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'wake_up_ai_alarm',
          'WakeUp AI alarm',
          channelDescription: 'Exercise-based alarm notifications',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: alarm.id,
    );
  }

  Future<void> cancel(WakeAlarm alarm) {
    return _notifications.cancel(_notificationId(alarm.id));
  }

  int _notificationId(String alarmId) {
    return alarmId.hashCode & 0x7fffffff;
  }
}
