import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reminder_app/constants.dart';
import 'package:reminder_app/service/notification.dart';
import 'package:reminder_app/service/task.dart';

import '../model/task.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final TaskService _taskService = TaskService();
  final NotificationService _notificationService = NotificationService();
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: adjustCardPriorityColor(widget.task.priority),
      child: SizedBox(
        height: 160,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                children: [
                  Expanded(
                      flex: 4,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(widget.task.title),
                      )),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Text(
                        widget.task.time,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      widget.task.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                Expanded(
                    flex: 4,
                    child: ListTile(
                      horizontalTitleGap: 0,
                      leading: Icon(
                        Icons.repeat_outlined,
                        size: 30,
                        color: mainTheme.primaryColor,
                      ),
                      title: Text(
                        widget.task.repetition == "No Repetition" ? "None" : widget.task.repetition,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                    padding: const EdgeInsets.only(right: 40),
                    onPressed: () {
                      _taskService.deleteTask(widget.task.id!);
                      _notificationService.cancelNotificationById(widget.task.notificationId);
                    },
                    icon: Icon(
                      Icons.delete,
                      size: 30,
                      color: mainTheme.primaryColor,
                    )),
              ],
            )
          ],
        ),
      ),
    );
  }

  Color adjustCardPriorityColor(String priority) {
    switch (priority) {
      case "Minor":
        return Colors.grey;
      case "Medium":
        return Colors.lightGreen;
      case "Major":
        return Colors.yellow;
      case "Critical":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String adjustDigitPrecision(int digit) {
    String digitStr = digit.toString();

    switch (digitStr.length) {
      case 1:
        return "0" + digitStr;
      default:
        return digitStr;
    }
  }
}
