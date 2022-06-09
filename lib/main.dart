import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reminder_app/pages/authorized_user.dart';
import 'package:reminder_app/service/auth.dart';
import 'package:reminder_app/service/notification.dart';
import 'package:reminder_app/service/person.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'builders.dart';
import 'constants.dart';
import 'model/person.dart' as models;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);
  NotificationService().configureLocalTimeZone();
  runApp(MaterialApp(
    home: const ReminderApp(),
    debugShowCheckedModeBanner: false,
    theme: mainTheme,
    initialRoute: FirebaseAuth.instance.currentUser == null ? ReminderApp.routeName : AuthorizedPersonPage.routeName,
    routes: {
      ReminderApp.routeName: (context) => const ReminderApp(),
      AuthorizedPersonPage.routeName: (context) => const AuthorizedPersonPage(),
    },
  ));

  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: NotificationService().onSelectNotification);
}

class ReminderApp extends StatefulWidget {
  static String routeName = "Reminder";

  const ReminderApp({Key? key}) : super(key: key);

  @override
  _ReminderAppState createState() => _ReminderAppState();
}

class _ReminderAppState extends State<ReminderApp> {
  final AuthService _authService = AuthService();
  final PersonService _personService = PersonService();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  late StreamSubscription<User?> user;

  String _name = "";
  String _email = "";
  String _password = "";
  String _confirmPassword = "";
  bool _visible = true;
  bool _hasAccount = true;
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: mainTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0, top: 40),
                child: Text("WELCOME",
                    style: GoogleFonts.getFont("Dancing Script",
                        fontWeight: FontWeight.bold, fontSize: 50, letterSpacing: 15, color: mainTheme.primaryColor)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 20),
                child: Center(
                  child: Text("Reminder\nAssistant\nApp",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.getFont(
                        "Dancing Script",
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        letterSpacing: 10,
                        color: mainTheme.primaryColor,
                      )),
                ),
              ),
              !_hasAccount
                  ? CustomCard(
                      padding: const EdgeInsets.all(8.0),
                      backGroundColor: mainTheme.backgroundColor,
                      borderRadius: 10.0,
                      horizontalMargin: 20.0,
                      verticalMargin: 10.0,
                      child: CustomTextField(
                        hintText: "Name",
                        fontSize: 20,
                        textColor: Colors.black,
                        onChanged: (value) {
                          _name = value;
                        },
                        prefixIcon: Icon(Icons.person, color: mainTheme.primaryColor),
                      ),
                    )
                  : const SizedBox(),
              Padding(
                padding: _hasAccount ? const EdgeInsets.only(top: 30.0) : const EdgeInsets.all(0.0),
                child: CustomCard(
                  padding: const EdgeInsets.all(8.0),
                  backGroundColor: mainTheme.backgroundColor,
                  borderRadius: 10.0,
                  horizontalMargin: 20.0,
                  verticalMargin: 10.0,
                  child: CustomTextField(
                    hintText: "E-Mail",
                    fontSize: 20,
                    controller: _emailController,
                    textColor: Colors.black,
                    onChanged: (value) {
                      _email = value;
                    },
                    prefixIcon: const Icon(Icons.email, color: Colors.lightBlue),
                  ),
                ),
              ),
              CustomCard(
                padding: const EdgeInsets.all(8.0),
                backGroundColor: mainTheme.backgroundColor,
                borderRadius: 10.0,
                horizontalMargin: 20.0,
                verticalMargin: 10.0,
                child: CustomTextField(
                  hintText: "Password",
                  controller: _passwordController,
                  fontSize: 20,
                  textColor: Colors.black,
                  isObscureText: !_visible,
                  onChanged: (value) {
                    _password = value;
                  },
                  prefixIcon: const Icon(Icons.security, color: Colors.red),
                  suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _visible = !_visible;
                        });
                      },
                      icon: _visible
                          ? Icon(
                              Icons.visibility,
                              color: mainTheme.primaryColor,
                            )
                          : Icon(Icons.visibility_off, color: mainTheme.primaryColor)),
                ),
              ),
              _hasAccount
                  ? ListTile(
                      horizontalTitleGap: 0,
                      leading: Checkbox(
                          side: MaterialStateBorderSide.resolveWith(
                            (states) => BorderSide(width: 2.0, color: mainTheme.primaryColor),
                          ),
                          activeColor: mainTheme.primaryColor,
                          value: _isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              _isChecked = !_isChecked;
                            });
                          }),
                      title: const Text(
                        "Remember Me",
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                      ))
                  : const SizedBox(),
              !_hasAccount
                  ? CustomCard(
                      padding: const EdgeInsets.all(8.0),
                      backGroundColor: mainTheme.backgroundColor,
                      borderRadius: 10.0,
                      horizontalMargin: 20.0,
                      verticalMargin: 10.0,
                      child: CustomTextField(
                        hintText: "Re-Password",
                        fontSize: 20,
                        textColor: Colors.black,
                        isObscureText: !_visible,
                        onChanged: (value) {
                          _confirmPassword = value;
                        },
                        prefixIcon: const Icon(Icons.security, color: Colors.red),
                      ),
                    )
                  : const SizedBox(),
              CustomCard(
                backGroundColor: Colors.deepPurple,
                borderRadius: 20.0,
                padding: const EdgeInsets.all(8.0),
                verticalMargin: 25.0,
                horizontalMargin: 120.0,
                child: CustomTextButton(
                  text: _hasAccount ? "Login" : " Sign Up",
                  textStyle: const TextStyle(color: Colors.white, fontSize: 25),
                  onPressed: () async {
                    bool _authSuccess = true;

                    if (_hasAccount) {
                      await _authService.signIn(_email, _password).catchError((e) {
                        Fluttertoast.showToast(msg: e.toString().split("]")[1], webShowClose: true, webPosition: "center", timeInSecForIosWeb: 3);
                        _authSuccess = false;
                      });
                    }

                    if (_name.isEmpty && !_hasAccount) {
                      Fluttertoast.showToast(msg: "Field 'name' can not be empty!", webShowClose: true, webPosition: "center", timeInSecForIosWeb: 3);
                    }

                    if (_password.compareTo(_confirmPassword) != 0 && !_hasAccount) {
                      Fluttertoast.showToast(msg: "Passwords are not the same", webShowClose: true, webPosition: "center", timeInSecForIosWeb: 3);
                    }

                    if (!_hasAccount) {
                      await _personService.createPerson(models.Person(name: _name, email: _email), _password).catchError((e) {
                        Fluttertoast.showToast(msg: e.toString().split("]")[1], webShowClose: true, webPosition: "center", timeInSecForIosWeb: 3);
                        _authSuccess = false;
                      });
                    }

                    if (_authSuccess) {
                      _saveUserCredentials(_isChecked);
                      switchPage(context, const AuthorizedPersonPage());
                    }
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _hasAccount ? "Does Not Have Account ?" : "Have An Account ? ",
                    style: const TextStyle(fontSize: 15, color: Colors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _hasAccount = !_hasAccount;
                        });
                      },
                      child: Text(
                        _hasAccount ? "Sign Up" : "Login",
                        textAlign: TextAlign.end,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.deepPurple),
                      ),
                    ),
                  )
                ],
              )
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _saveUserCredentials(bool? value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    if (!_isChecked) {
      sharedPreferences.clear();
      debugPrint("user does not want to be remembered!");
      return;
    }

    sharedPreferences.setBool("remember_me", _isChecked);
    sharedPreferences.setString('email', _email);
    sharedPreferences.setString('password', _password);
  }

  @override
  void initState() {
    super.initState();
    _loadUserEmailPassword();
    user = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        debugPrint('User is currently signed out!');
      } else {
        debugPrint('User is signed in!');
      }
    });
  }

  @override
  void dispose() {
    user.cancel();
    super.dispose();
  }

  void _loadUserEmailPassword() async {
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _savedEmail = _prefs.getString("email") ?? "";
      var _savedPassword = _prefs.getString("password") ?? "";
      var _savedRememberMe = _prefs.getBool("remember_me") ?? false;

      // debugPrint(_savedEmail);
      // debugPrint(_savedPassword);
      // debugPrint(_savedRememberMe.toString());
      if (_savedRememberMe) {
        setState(() {
          _isChecked = true;
          _email = _savedEmail ?? "";
          _password = _savedPassword ?? "";
          _emailController.text = _email;
          _passwordController.text = _password;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
