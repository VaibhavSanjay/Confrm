import 'package:family_tasks/models/user_data.dart';
import 'package:flutter/material.dart';

enum TaskType {
  garbage,
  shopping,
  cooking,
  cleaning,
  other
}

// A class to represent the data for a task
class TaskData {
  late String name; // User provided name for a task
  late TaskType taskType; // User provided type of task
  late String desc; // User provided task description (optional)
  late ColorSwatch color;
  late DateTime due;
  late DateTime archived;
  late String location;
  late List<double> coords;
  late DateTime lastRem;
  late String completedBy;
  late List<String> assignedUsers;

  TaskData({this.name = 'New Task', this.taskType = TaskType.other, this.desc = '', this.color = Colors.grey,
    this.location = '', List<double>? coords, DateTime? due, DateTime? archived, DateTime? lastRem,
    this.completedBy = '', List<String>? assignedUsers}) {
      this.due = due ?? DateTime.now().toUtc().add(const Duration(minutes: 5));
      this.archived = archived ?? DateTime(2101);
      this.lastRem = lastRem ?? DateTime.now().toUtc().subtract(const Duration(minutes: 15));
      this.coords = coords ?? [];
      this.assignedUsers = assignedUsers ?? [];
    }

    TaskData.fromTaskData(TaskData td) {
      name = td.name;
      taskType = td.taskType;
      desc = td.desc;
      color = td.color;
      due = td.due;
      archived = td.archived;
      location = td.location;
      coords = td.coords;
      lastRem = td.lastRem;
      completedBy = td.completedBy;
      assignedUsers = td.assignedUsers;
    }

}

class FamilyTaskData {
  final List<TaskData> tasks;
  final List<TaskData> archive;
  final Map<String, UserData> users;
  final String name;

  FamilyTaskData({this.tasks = const [], this.name = 'New Family', this.archive = const [], this.users = const {}});
}