import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

const FirebaseOptions options = FirebaseOptions(
    apiKey: "AIzaSyBQGsZZA1_Ffkdqz6PPsDh08VAtVdggQxY",
    appId: "1:1064158595393:android:1fbf753402a657d78039c0",
    messagingSenderId: "1064158595393",
    projectId: "reminder-assistant-9e6a4",
    authDomain: "reminder-assistant-9e6a4.firebaseapp.com",
    storageBucket: "reminder-assistant-9e6a4.appspot.com");

const String initialTimeText = "Open Time Picker";
const String microSecondsSeparator = ".";
const errorTypeSeparator = "]";
const sentenceSeparator = ".";

final ThemeData mainTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColorDark: Colors.grey,
  primaryColor: Colors.deepPurple,
  backgroundColor: Colors.white70,
  fontFamily: 'Georgia',
  textTheme: const TextTheme(
    headline1: TextStyle(color: Colors.black, fontSize: 36.0, fontWeight: FontWeight.bold),
    headline2: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
    headline3: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: Colors.white),
    headline4: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
    headline5: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
    headline6: TextStyle(fontSize: 25.0, fontStyle: FontStyle.italic, color: Colors.black),
    bodyText1: TextStyle(fontSize: 18.0, color: Colors.black),
    bodyText2: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
  ),
);

const DatePickerTheme datePickerTheme = DatePickerTheme(
    headerColor: Colors.deepPurple,
    backgroundColor: Colors.orangeAccent,
    cancelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
    itemStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    doneStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18));

const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('repeating channel id', 'repeating channel name',
    channelDescription: 'repeating description', enableVibration: true, importance: Importance.max, priority: Priority.high);
const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

const InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
);

createRandomNotificationId() {
  return DateTime.now().microsecondsSinceEpoch;
}

void showToastMessage(String message, Color textColor, double fontSize) {
  Fluttertoast.showToast(
      msg: message,
      backgroundColor: mainTheme.backgroundColor,
      fontSize: fontSize,
      timeInSecForIosWeb: message.length > 40 ? 4 : 2,
      textColor: textColor,
      toastLength: message.length > 40 ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT,
      webPosition: "center");
}

int convertPriorityToInteger(String priority) {
  switch (priority) {
    case TaskPriority.minor:
      return TaskPriority.one;
    case TaskPriority.medium:
      return TaskPriority.two;
    case TaskPriority.major:
      return TaskPriority.three;
    case TaskPriority.critical:
      return TaskPriority.four;
    default:
      return TaskPriority.one;
  }
}

String convertPriorityToString(int priority) {
  switch (priority) {
    case TaskPriority.one:
      return TaskPriority.minor;
    case TaskPriority.two:
      return TaskPriority.medium;
    case TaskPriority.three:
      return TaskPriority.major;
    case TaskPriority.four:
      return TaskPriority.critical;
    default:
      return TaskPriority.minor;
  }
}

String convertSelectionToFieldName(String selectedSortType) {
  switch (selectedSortType) {
    case SortType.byPriorityDesc:
    case SortType.byPriorityAsc:
      return FieldName.priority;
    case SortType.byDateAsc:
    case SortType.byDateDesc:
    default:
      return FieldName.time;
  }
}

List<String> createDialogElements(String job) {
  List<String> elements = [];

  switch (job) {
    case Job.none:
      break;
    case Job.makePhoneCall:
      elements.add("Phone Number");
      break;
    case Job.sendEmail:
      elements.add("Email Address");
      elements.add("Subject");
      elements.add("Body");
      break;
    case Job.sendSms:
      elements.add("Phone Number");
      elements.add("Body");
      break;
    case Job.openUrl:
      elements.add("Url");
      break;
  }

  return elements;
}

String createErrorInfo(String fieldName) {
  return "Field $fieldName can not be empty!";
}

class ErrorString {
  static const password = "Passwords are not the same";
  static const repetition = "Please set a repetition option";
  static const time = "Please set a start time";
  static const timeAndRepetitionMissMatch = "With This Repetition Option Time can not be chosen...";
}

class FieldName {
  static const password = "password";
  static const repetition = "repetition";
  static const time = "time";
  static const name = "name";
  static const email = "email";
  static const description = "description";
  static const title = "title";
  static const priority = "priority";
  static const rememberMe = "rememberMe";
  static const uid = "uid";
}

class Repetition {
  static const none = "None";
  static const minutely = "Every Minute";
  static const hourly = "Hourly";
  static const daily = "Daily";
  static const weekly = "Weekly";
  static const monthly = "Monthly";
  static const yearly = "Yearly";

  static const List<String> items = <String>[
    Repetition.none,
    Repetition.minutely,
    Repetition.hourly,
    Repetition.daily,
    Repetition.weekly,
    Repetition.monthly,
    Repetition.yearly
  ];
}

class Job {
  static const none = "None";
  static const makePhoneCall = "Phone Call";
  static const sendEmail = "Send Email";
  static const sendSms = "Send Sms";
  static const openUrl = "Open Url";

  static const List<String> items = <String>[Job.none, Job.makePhoneCall, Job.sendEmail, Job.sendSms, Job.openUrl];
}

class TaskPriority {
  static const minor = "Minor";
  static const medium = "Medium";
  static const major = "Major";
  static const critical = "Critical";

  static const one = 1;
  static const two = 2;
  static const three = 3;
  static const four = 4;

  static const List<String> items = <String>[TaskPriority.minor, TaskPriority.medium, TaskPriority.major, TaskPriority.critical];
}

class SortType {
  static const byDateAsc = "By Date (Asc)";
  static const byDateDesc = "By Date (Desc)";
  static const byPriorityAsc = "By Priority (Asc)";
  static const byPriorityDesc = "By Priority (Desc)";

  static const List<String> items = <String>[SortType.byDateAsc, SortType.byDateDesc, SortType.byPriorityAsc, SortType.byPriorityDesc];
}

const emptyWidget = SizedBox();
