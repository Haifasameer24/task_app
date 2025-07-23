// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:getx_course/main.dart';
// import 'package:timezone/timezone.dart' as tz;
//
// Future<void> scheduleTaskNotification({
//   required int id,
//   required String title,
//   required String body,
//   required DateTime scheduledTime,
// }) async {
//   const androidDetails = AndroidNotificationDetails(
//     'task_channel_id',
//     'Task Channel',
//     channelDescription: 'Reminder for tasks',
//     importance: Importance.max,
//     priority: Priority.high,
//   );
//
//   const notificationDetails = NotificationDetails(android: androidDetails);
//
//   await flutterLocalNotificationsPlugin.zonedSchedule(
//     id,
//     title,
//     body,
//     tz.TZDateTime.from(scheduledTime, tz.local),
//     notificationDetails,
//     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//     matchDateTimeComponents: DateTimeComponents.dateAndTime,
//   );
// }