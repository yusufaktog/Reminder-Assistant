import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:reminder_app/builders.dart';
import 'package:reminder_app/model/person.dart' as models;
import 'package:reminder_app/pages/authorized_user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../model/notification.dart';
import '../pages/detailed_task_page.dart';

class NotificationService {
  String? selectedNotificationPayload;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Streams are created so that app can respond to notification-related events
  /// since the plugin is initialised in the `main` function
  final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();

  final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();

  Future<void> configureLocalTimeZone() async {
    if (kIsWeb) {
      return;
    }
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

  void configureSelectNotificationSubject(context, models.Person person) {
    selectNotificationSubject.stream.listen((String? payload) async {
      await switchPage(context, AuthorizedPersonPage(person: person));
    });
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationById(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  void configureDidReceiveLocalNotificationSubject(context) {
    didReceiveLocalNotificationSubject.stream.listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null ? Text(receivedNotification.title!) : null,
          content: receivedNotification.body != null ? Text(receivedNotification.body!) : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                await Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => DetailedTaskPage(),
                  ),
                );
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  Future<void> createScheduledNotificationWithInterval(String title, String body, int notificationId, RepeatInterval repeatInterval) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('repeating channel id', 'repeating channel name',
        channelDescription: 'repeating description', enableVibration: true, importance: Importance.max, priority: Priority.max);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(notificationId, title, body, repeatInterval, platformChannelSpecifics,
        androidAllowWhileIdle: true);
  }

  Future<void> createCustomScheduledNotification(
      String title, String body, int notificationId, DateTime dateTime, RepetitionType repetitionType) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        createScheduledDate(dateTime),
        const NotificationDetails(
          android: AndroidNotificationDetails('daily notification channel id', 'daily notification channel name',
              channelDescription: 'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: convertToDateTimeComponents(repetitionType));
  }

  tz.TZDateTime createScheduledDate(DateTime dateTime) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.getLocation("Europe/Izmir"));

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // daily ise
  // DateTimeComponents.time

  // weekly ise
  // DateTimeComponents.dayOfWeekAndTime

  // monthly ise
  // DateTimeComponents.dayOfMonthAndTime

  // yearly ise
  // DateTimeComponents.dateAndTime

  DateTimeComponents convertToDateTimeComponents(RepetitionType repetitionType) {
    switch (repetitionType) {
      case RepetitionType.daily:
        return DateTimeComponents.time;
      case RepetitionType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepetitionType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepetitionType.yearly:
        return DateTimeComponents.dateAndTime;
    }
  }
}
