import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/constants.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/model/task.dart';
import 'package:reminder_app/pages/task_card.dart';
import 'package:reminder_app/service/auth.dart';
import 'package:reminder_app/service/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../builders.dart';
import 'create_task.dart';

class AuthorizedPersonPage extends StatefulWidget {
  static String routeName = "Authorized";

  const AuthorizedPersonPage({Key? key}) : super(key: key);

  @override
  _AuthorizedPersonPageState createState() => _AuthorizedPersonPageState();
}

class _AuthorizedPersonPageState extends State<AuthorizedPersonPage> {
  final AuthService _authService = AuthService();

  var _selectedItem = "";
  var _selectedSortFieldName = FieldName.time;
  var _isDescending = false;
  final List<String> _dropDownMenuItems = List.of(SortType.items);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainTheme.primaryColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Active Tasks",
                        style: mainTheme.textTheme.headline2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _authService.signOut().then((value) => switchPage(context, const ReminderApp()));
                        },
                        icon: const Icon(Icons.logout, color: Colors.red, size: 25))
                  ],
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 10),
                  child: CustomDropDownMenu(
                    icon: const Icon(
                      Icons.sort_sharp,
                      size: 30,
                      color: Colors.white,
                    ),
                    onChanged: (dynamic value) async {
                      _selectedItem = value;
                      setState(() {
                        _dropDownMenuItems.remove(value);
                        _dropDownMenuItems.insert(0, value);
                        _selectedSortFieldName = convertSelectionToFieldName(_selectedItem);
                        _isDescending = _selectedItem.contains("Desc") ? true : false;
                      });
                    },
                    dropDownValue: _dropDownMenuItems.first,
                    items: _dropDownMenuItems,
                    dropDownColor: Colors.white,
                    itemTextStyle: mainTheme.textTheme.bodyText2,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: mainTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("People")
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection("Tasks")
                      .orderBy(_selectedSortFieldName, descending: _isDescending)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return snapshot.connectionState != ConnectionState.waiting
                        ? ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.size,
                            itemBuilder: (context, index) {
                              var tasks = snapshot.data!.docs;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                                    child: TaskCard(
                                      task: Task(
                                          id: tasks[index]["id"],
                                          title: tasks[index]["title"],
                                          description: tasks[index]["description"],
                                          time: tasks[index]["time"],
                                          priority: convertPriorityToString(tasks[index]["priority"]),
                                          notificationId: tasks[index]["notificationId"],
                                          repetition: tasks[index]['repetition'],
                                          jop: tasks[index].data().toString().contains("job") ? tasks[index]["job"] : Job.none),
                                    ),
                                  ),
                                ),
                              );
                            })
                        : const Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
            ],
          ),
        ),
        bottomNavigationBar: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Add Task",
                style: mainTheme.textTheme.headline6,
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateTaskPage(),
                    ),
                  );
                },
                icon: Icon(Icons.add_box, size: 30, color: mainTheme.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _runWhileAppIsTerminated();
  }
}

void _runWhileAppIsTerminated() async {
  var details = await NotificationService().flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

  if (!details!.didNotificationLaunchApp) {
    return;
  }

  if (details.payload == null) {
    return;
  }

  final prefs = await SharedPreferences.getInstance();

  if (prefs.get(FieldName.uid) == null) {
    return;
  }

  NotificationService().onSelectNotification(details.payload);
}
