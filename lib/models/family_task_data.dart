import 'package:flutter/material.dart';

enum TaskType {
  garbage,
  shopping,
  cooking,
  cleaning,
  other
}

enum Status {
  inProgress,
  start,
  complete
}

// A class to represent the data for a task
class TaskData {
  late String name; // User provided name for a task
  late TaskType taskType; // User provided type of task
  late String desc; // User provided task description (optional)
  late ColorSwatch color;
  late Status status;
  late DateTime due;

  TaskData({this.name = '', this.taskType = TaskType.other, this.desc = '', this.color = Colors.grey,
    this.status = Status.inProgress, DateTime? due}) : due = due ?? DateTime.now().toUtc().add(const Duration(minutes: 5));

  TaskData.fromTaskData(TaskData td) {
    name = td.name;
    taskType = td.taskType;
    desc = td.desc;
    color = td.color;
    status = td.status;
    due = td.due;
  }

}

class FamilyTaskData {
  final List<TaskData> tasks;
  final String name;

  FamilyTaskData({this.tasks = const [], this.name = 'New Family'});
}