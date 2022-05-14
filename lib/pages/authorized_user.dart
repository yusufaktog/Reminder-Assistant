import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/builders.dart';
import 'package:reminder_app/constants.dart';
import 'package:reminder_app/model/task.dart';
import 'package:reminder_app/pages/task_card.dart';
import 'package:reminder_app/service/task.dart';

import '../model/person.dart';
import 'create_task.dart';
import 'detailed_task_page.dart';

class AuthorizedPersonPage extends StatefulWidget {
  final Person person;

  const AuthorizedPersonPage({Key? key, required this.person}) : super(key: key);

  @override
  _AuthorizedPersonPageState createState() => _AuthorizedPersonPageState();
}

class _AuthorizedPersonPageState extends State<AuthorizedPersonPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                                          priority: tasks[index]["priority"]),
                                    ),
                                  ),
                                ),
                              );
                            })
                        : const Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
              TextButton(
                  onPressed: () {
                    TaskService _taskService = TaskService();
                    _taskService
                        .createTask(Task(title: "title", description: "Test Descr", time: Timestamp.fromDate(DateTime.now()), priority: "Minor"));
                  },
                  child: Text(
                    widget.person.name,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 30),
                  ))
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 75,
          color: mainTheme.backgroundColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  switchPage(context, const CreateTaskPage());
                },
                icon: Icon(Icons.add_box, size: 30, color: mainTheme.primaryColor),
              ),
              Text(
                "Add Task",
                style: mainTheme.textTheme.headline6,
              )
            ],
          ),
        ),
      ),
    );
  }
}
