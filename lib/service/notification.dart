import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';
import '../model/notification.dart';
import 'jop.dart';

class NotificationService {
  // String? selectedNotificationPayload;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
/*  final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();
  final LocalStorageService _localStorageService = LocalStorageService();*/

  Future<void> configureLocalTimeZone() async {
    if (kIsWeb) {
      return;
    }
    tz.initializeTimeZones();
    final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName!));
  }

/*
  void configureSelectNotificationSubject(context, models.Person person) {
    selectNotificationSubject.stream.listen((String? payload) async {

    });
  }
*/

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotificationById(int notificationId) async {
    await flutterLocalNotificationsPlugin.cancel(notificationId);
  }

  Future<void> createScheduledNotificationWithRepeatInterval(
      String title, String body, int notificationId, RepeatInterval repeatInterval, String taskId) async {
    await flutterLocalNotificationsPlugin.periodicallyShow(notificationId, title, body, repeatInterval, platformChannelSpecifics,
        payload: taskId, androidAllowWhileIdle: true);
    flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  Future<void> createScheduledNotificationWithNoRepetition(String title, String body, int notificationId, DateTime dateTime, String taskId) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(notificationId, title, body, createScheduledDate(dateTime), platformChannelSpecifics,
        payload: taskId, androidAllowWhileIdle: true, uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> createCustomScheduledNotification(
      String title, String body, int notificationId, DateTime dateTime, RepetitionType repetitionType, String taskId) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(notificationId, title, body, createScheduledDate(dateTime), platformChannelSpecifics,
        payload: taskId,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: convertToDateTimeComponents(repetitionType));
  }

  tz.TZDateTime createScheduledDate(DateTime dateTime) {
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(dateTime, tz.getLocation("Europe/Istanbul"));
    return scheduledDate;
  }

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

  Future onSelectNotification(String? payload) async {
    String phoneNumber = "";
    String emailAddress = "";
    String url = "";
    String subject = "";
    String body = "";
    String jop = "none";

    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('People')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("Tasks")
        .doc(payload)
        .snapshots()
        .firstWhere((element) => element.id == payload);

    if (!documentSnapshot.exists) {
      return;
    }

    jop = documentSnapshot["jop"];

    switch (jop.toLowerCase()) {
      case "open url":
        url = documentSnapshot["url"];
        await openUrl(url);
        break;

      case "phone call":
        phoneNumber = documentSnapshot["phoneNumber"];
        await makePhoneCall(phoneNumber);
        break;

      case "send email":
        emailAddress = documentSnapshot["emailAddress"];
        subject = documentSnapshot["subject"];
        body = documentSnapshot["body"];
        await sendEmail(emailAddress, subject, body);
        break;

      case "send sms":
        phoneNumber = documentSnapshot["phoneNumber"];
        body = documentSnapshot["body"];
        await sendSms(phoneNumber, body);
        break;

      case "none":
      default:
        break;
    }
  }
}
