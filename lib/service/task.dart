import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../model/task.dart';

class TaskService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createTask(Task task) async {
    var doc = _firestore.collection("People").doc(_auth.currentUser!.uid).collection("Tasks").doc();
    await doc.set({
      'id': doc.id,
      'title': task.title,
      'description': task.description,
      'time': task.time,
      'priority': convertPriorityToInteger(task.priority),
      'notificationId': task.notificationId,
      'repetition': task.repetition
    });
    return doc.id;
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection("People").doc(_auth.currentUser!.uid).collection("Tasks").doc(taskId).delete();
  }

  DocumentReference<Map<String, dynamic>> getDocRef(String docId) {
    return _firestore.collection("People").doc(_auth.currentUser!.uid).collection("Tasks").doc(docId);
  }
}
