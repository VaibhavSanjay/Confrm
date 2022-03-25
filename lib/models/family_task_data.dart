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
  late DateTime archived;

  TaskData({this.name = 'New Task', this.taskType = TaskType.other, this.desc = '', this.color = Colors.grey,
    this.status = Status.start, DateTime? due, DateTime? archived}) {
      this.due = due ?? DateTime.now().toUtc().add(const Duration(minutes: 5));
      this.archived = archived ?? DateTime(2101);
    }

    TaskData.fromTaskData(TaskData td) {
      name = td.name;
      taskType = td.taskType;
      desc = td.desc;
      color = td.color;
      status = td.status;
      due = td.due;
      archived = td.archived;
    }

}

class FamilyTaskData {
  final List<TaskData> tasks;
  final List<TaskData> archive;
  final String name;

  FamilyTaskData({this.tasks = const [], this.name = 'New Family', this.archive = const []});
}