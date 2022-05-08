import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reminder_app/model/notification.dart';

class Task {
  final String title;
  final String description;
  final Timestamp time;
  final String priority;
  final Notification? notification;

  Task({required this.priority, required this.time, required this.title, this.notification, required this.description});
}
