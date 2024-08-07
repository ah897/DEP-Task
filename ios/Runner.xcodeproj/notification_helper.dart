import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationHelper {
  static final _notification = FlutterLocalNotificationsPlugin();

  static init() {
    _notification.initialize(const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher')));


    tz.initializeTimeZones();
  }

  static Future<void> scheduleNotification(String title, String body, DateTime scheduledDate) async {
    var androidDetails = AndroidNotificationDetails(
      'notification_channel_id',
      'My Channel',
      channelDescription: 'Channel for To-Do Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    var notificationDetails = NotificationDetails(android: androidDetails);

    tz.TZDateTime scheduledTime = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notification.zonedSchedule(
      0,
      title,
      body,
      scheduledTime,
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
