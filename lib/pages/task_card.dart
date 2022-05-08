import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../model/task.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: adjustCardPriorityColor(widget.task.priority),
      child: SizedBox(
        height: 120,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 6.0),
              child: Row(
                children: [
                  Expanded(flex: 4, child: Text(widget.task.description)),
                  Expanded(
                    flex: 1,
                    child: Text(
                      adjustTimeStr(widget.task.time),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Text(widget.task.description)
          ],
        ),
      ),
    );
  }

  String adjustTimeStr(Timestamp time) {
    DateTime dateTime = time.toDate();

    return adjustDigitPrecision(dateTime.day) +
        "/" +
        adjustDigitPrecision(dateTime.month) +
        " - " +
        adjustDigitPrecision(dateTime.hour) +
        ":" +
        adjustDigitPrecision(dateTime.minute);
  }

  Color adjustCardPriorityColor(String priority) {
    switch (priority) {
      case "Minor":
        return Colors.grey;
      case "Medium":
        return Colors.green;
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
