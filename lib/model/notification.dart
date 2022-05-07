class Notification {
  final String? id;
  final Type notificationType;
  final int timeToRepeat;
  final int numberOfRepetitions;

  Notification(this.id, this.notificationType, this.timeToRepeat, this.numberOfRepetitions);
}

enum Type { eMail, mobile }
