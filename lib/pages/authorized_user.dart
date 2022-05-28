import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reminder_app/builders.dart';
import 'package:reminder_app/constants.dart';
import 'package:reminder_app/model/task.dart';
import 'package:reminder_app/pages/task_card.dart';
import 'package:reminder_app/service/notification.dart';

import '../model/person.dart' as models;
import 'create_task.dart';
import 'detailed_task_page.dart';

class AuthorizedPersonPage extends StatefulWidget {
  final models.Person person;

  const AuthorizedPersonPage({Key? key, required this.person}) : super(key: key);

  @override
  _AuthorizedPersonPageState createState() => _AuthorizedPersonPageState();
}

class _AuthorizedPersonPageState extends State<AuthorizedPersonPage> {
  late AndroidNotificationChannel channel;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final NotificationService _notificationService = NotificationService();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          elevation: 2.0,
          backgroundColor: mainTheme.primaryColor,
          title: Text("Active Tasks", style: mainTheme.textTheme.headline2),
          centerTitle: true,
        ),
        backgroundColor: mainTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("People").doc(widget.person.id).collection("Tasks").snapshots(),
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
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => DetailedTaskPage(),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                                    child: TaskCard(
                                      task: Task(
                                        title: tasks[index]["title"],
                                        description: tasks[index]["description"],
                                        time: tasks[index]["time"],
                                        priority: tasks[index]["priority"],
                                        notificationId: tasks[index]["notificationId"],
                                      ),
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
                  switchPage(context, const CreateTaskPage());
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
    _notificationService.configureDidReceiveLocalNotificationSubject(context);
    _notificationService.configureSelectNotificationSubject(context, widget.person);
    //_notificationService.createCustomScheduledNotification("title", "body", DateTime.now().add(const Duration(seconds: 15)), RepetitionType.daily);
    _notificationService.createScheduledNotificationWithInterval("title", "body", createRandomNotificationId(), RepeatInterval.everyMinute);
  }
}
