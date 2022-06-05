class Task {
  final String? id;
  final String title;
  final String description;
  final String time;
  final String priority;
  final int notificationId;
  final String repetition;
  final String? jop;

  Task(
      {this.id,
      this.jop,
      required this.repetition,
      required this.priority,
      required this.time,
      required this.title,
      required this.notificationId,
      required this.description});
}
