import 'package:reminder_app/model/task.dart';

class Person {
  final String? id;
  final String name;
  final String email;

  List<Task>? tasks = [];

  Person({this.id, required this.name, required this.email});
}
