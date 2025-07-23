import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await requestPermission();

    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
  }

  static Future<void> requestPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  /// إشعار فوري
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Notifications',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  /// جدولة إشعار بتاريخ ووقت كامل
  static Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
  }) async {
    var scheduledDate = tz.TZDateTime(
      tz.local,
      year,
      month,
      day,
      hour,
      minute,
    );

    // طباعة التفاصيل
    print("🔔 جدول الإشعار:");
    print("👉 العنوان: $title");
    print("👉 النص: $body");
    print("👉 التاريخ: $year-$month-$day");
    print("👉 الوقت: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}");
    print("👉 كامل التاريخ: $scheduledDate");

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_channel_id',
          'Task Notifications',
          channelDescription: 'Notifications for task reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );

    print("✅ Doooonnnnnneeeee (تمت الجدولة)");
  }
}
