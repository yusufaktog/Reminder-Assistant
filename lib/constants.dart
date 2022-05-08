import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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
    headline1: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: Colors.black),
    headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic, color: Colors.black),
    bodyText1: TextStyle(fontSize: 18.0, fontFamily: 'Hind', color: Colors.black),
    bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind', color: Colors.black),
  ),

// Define the default `TextTheme`. Use this to specify the default
// text styling for headlines, titles, bodies of text, and more.
);
