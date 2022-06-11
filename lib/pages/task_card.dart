import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:reminder_app/service/notification.dart';
import 'package:reminder_app/service/task.dart';

import '../constants.dart';
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
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, top: 10),
                child: Column(
                  children: [
                    Text(
                      widget.task.title.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(widget.task.description,
                        style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.clip)
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_history_outlined, color: mainTheme.primaryColor),
                    const SizedBox(height: 5),
                    Text(widget.task.jop!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black, fontSize: 14))
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Text(
                      widget.task.time,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    ListTile(
                      contentPadding: const EdgeInsets.only(right: 8.0),
                      horizontalTitleGap: 0,
                      leading: Icon(
                        Icons.repeat_outlined,
                        size: 30,
                        color: mainTheme.primaryColor,
                      ),
                      title: Text(
                        widget.task.repetition,
                        style: const TextStyle(color: Colors.black, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                        padding: const EdgeInsets.only(left: 16.0),
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
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color adjustCardPriorityColor(String priority) {
    switch (priority) {
      case TaskPriority.minor:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.lightGreen;
      case TaskPriority.major:
        return Colors.yellow;
      case TaskPriority.critical:
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
