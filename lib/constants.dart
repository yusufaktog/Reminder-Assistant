import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'model/notification.dart';

const FirebaseOptions options = FirebaseOptions(
    apiKey: "AIzaSyBQGsZZA1_Ffkdqz6PPsDh08VAtVdggQxY",
    appId: "1:1064158595393:android:1fbf753402a657d78039c0",
    messagingSenderId: "1064158595393",
    projectId: "reminder-assistant-9e6a4",
    authDomain: "reminder-assistant-9e6a4.firebaseapp.com",
    storageBucket: "reminder-assistant-9e6a4.appspot.com");

class ThemeModel with ChangeNotifier {
  final ThemeMode _mode;

  ThemeMode get mode => _mode;

  ThemeModel(this._mode);
}

final ThemeData mainTheme = ThemeData(
// Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColorDark: Colors.grey,
  primaryColor: Colors.deepPurple,

  backgroundColor: Colors.white70,

// Define the default font family.
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

// Define the default `TextTheme`. Use this to specify the default
// text styling for headlines, titles, bodies of text, and more.
);

const DatePickerTheme datePickerTheme = DatePickerTheme(
    headerColor: Colors.deepPurple,
    backgroundColor: Colors.orangeAccent,
    cancelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
    itemStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
    doneStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18));

const String repetitionError = "Please set a repetition option";
const String timeError = "Please set a start time";
const String titleError = "Field 'Title' cant be empty";
const String descriptionError = "Field 'description' cant be empty";

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

showToastMessage(String message, Color textColor, double fontSize) {
  Fluttertoast.showToast(
      msg: message,
      backgroundColor: mainTheme.backgroundColor,
      fontSize: fontSize,
      timeInSecForIosWeb: 3,
      textColor: textColor,
      webPosition: "center");
}

RepetitionType convertStringToRepetitionType(String repetition) {
  switch (repetition.toLowerCase()) {
    case "daily":
      return RepetitionType.daily;
    case "weekly":
      return RepetitionType.weekly;
    case "monthly":
      return RepetitionType.monthly;
    case "yearly":
    default:
      return RepetitionType.yearly;
  }
}

int convertPriorityToInteger(String priority) {
  switch (priority.toLowerCase()) {
    case "minor":
      return 1;
    case "medium":
      return 2;
    case "major":
      return 3;
    case "critical":
      return 4;
    default:
      return 1;
  }
}

String convertPriorityToString(int priority) {
  switch (priority) {
    case 1:
      return "Minor";
    case 2:
      return "Medium";
    case 3:
      return "Major";
    case 4:
      return "Critical";
    default:
      return "Minor";
  }
}

String convertSelectionToFieldName(selectedSortType) {
  switch (selectedSortType) {
    case "By Priority (Desc)":
    case "By Priority (Asc)":
      return "priority";
    case "By Date (Desc)":
    case "By Date (Asc)":
    default:
      return "time";
  }
}
