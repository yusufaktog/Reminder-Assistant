import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../model/task.dart';

class TaskService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createTask(Task task) async {
    await _firestore.collection("People").doc(_auth.currentUser!.uid).collection("Tasks").doc().set({
      'title': task.title,
      'description': task.description,
      'time': task.time,
      'priority': convertPriorityToInteger(task.priority),
      'notificationId': task.notificationId
    });
  }
}
