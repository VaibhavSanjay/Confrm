import 'dart:core';
import 'package:family_tasks/Services/database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:reorderables/reorderables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:family_tasks/models/family_task_data.dart';

import 'Helpers/hero_dialogue_route.dart';
import 'Helpers/task_view_cards.dart';

class TaskViewPage extends StatefulWidget {
  const TaskViewPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<TaskViewPage> createState() => _TaskViewPageState();
}

class _TaskViewPageState extends State<TaskViewPage> {
  List<TaskData> _taskData = [
    TaskData(
        name: "Clean Sink",
        taskType: TaskType.cleaning,
        desc: 'Please clean the sink',
        status: Status.inProgress
    ),
    TaskData(
        name: "Take out trash",
        taskType: TaskType.garbage,
        color: Colors.red,
        status: Status.complete
    ),
    TaskData(
        name: "Cook",
        taskType: TaskType.cooking,
        desc: 'Food',
        color: Colors.purple,
        status: Status.start,
        due: DateTime.now().add(Duration(minutes: 10))
    ),
  ];
  final double _statusIconSize = 30;
  late final List<Reaction<Status>> _statusCardReactions;
  final List<String> daysOfWeek = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();

    _statusCardReactions = List<Reaction<Status>>.generate(
        Status.values.length,
            (int index) {
          return Reaction<Status>(
              previewIcon: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                    _getIconForStatus(Status.values.elementAt(index)),
                    color: _getColorForStatus(Status.values.elementAt(index)),
                    size: _statusIconSize
                ),
              ),
              icon: Icon(
                  _getIconForStatus(Status.values.elementAt(index)),
                  color: _getColorForStatus(Status.values.elementAt(index)),
                  size: _statusIconSize
              ),
              value: Status.values.elementAt(index)
          );
        }
    );
  }

  // A helper function to get the icon data based on a task type
  IconData _getIconForTaskType(TaskType tt) {
    switch (tt) {
      case TaskType.garbage:
        return FontAwesomeIcons.trash;
      case TaskType.cleaning:
        return FontAwesomeIcons.soap;
      case TaskType.cooking:
        return FontAwesomeIcons.utensils;
      case TaskType.shopping:
        return FontAwesomeIcons.cartShopping;
      case TaskType.other:
        return FontAwesomeIcons.star;
    }
  }

  IconData _getIconForStatus(Status s) {
    switch (s) {
      case Status.complete:
        return Icons.check_circle;
      case Status.start:
        return FontAwesomeIcons.hourglassStart;
      case Status.inProgress:
        return Icons.timelapse;
    }
  }

  Color _getColorForStatus(Status s) {
    switch (s) {
      case Status.complete:
        return Colors.greenAccent;
      case Status.start:
        return Colors.black;
      case Status.inProgress:
        return Colors.amber;
    }
  }

  Widget _createTaskCard(BuildContext context, int i) {
    return InkWell(
      child: Hero(
        tag: i,
        child: Card(
          color: _taskData[i].color,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(_getIconForTaskType(_taskData[i].taskType)), // Put the icon for the type of task
                title: Text(_taskData[i].name), // Name of task
                subtitle: Text('${daysOfWeek[_taskData[i].due.toLocal().weekday]}, '
                    '${DateFormat('h:mm a').format(_taskData[i].due.toLocal())}'), // Due date
                trailing: ReactionButton<Status>(
                  boxPosition: Position.BOTTOM,
                  boxElevation: 10,
                  onReactionChanged: (Status? value) {
                    _taskData[i].status = value ?? Status.inProgress;
                  },
                  initialReaction: Reaction<Status>(
                      icon: Icon(
                          _getIconForStatus(_taskData[i].status),
                          color: _getColorForStatus(_taskData[i].status),
                          size: _statusIconSize
                      ),
                      value: _taskData[i].status
                      ),
                  reactions: _statusCardReactions,
                  boxDuration: const Duration(milliseconds: 100),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return EditTaskData(
            selectedTask: i,
            taskData: TaskData.fromTaskData(_taskData.elementAt(i)),
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/6, left: 30, right: 30, bottom: MediaQuery.of(context).size.height/6),
            onExit: (TaskData? data) {
              if (data != null) {
                _taskData[i] = TaskData.fromTaskData(data);
              }
              Navigator.of(context).pop();
              setState((){});
            },
          );
          //return _createTaskEditCard(context, i);
        }));
      },
      key: ValueKey(i), // The reorderables package requires a key for each of its elements
    );
  }

  @override
  Widget build(BuildContext context) {
    /* This widget is rebuilt on every reorder.
       So we must remake the list of task cards based on the list of task data.
     */

    return StreamBuilder<FamilyTaskData>(
      stream: DatabaseService('100').taskDataForFamily,
      builder: (context, AsyncSnapshot<FamilyTaskData> snapshot) {
        if (snapshot.hasError) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Icon(Icons.error_outline, size: 100),
              Text('Error!', style: TextStyle(fontSize: 30))
            ]
          );
        } else {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                )
              );
            case ConnectionState.active:
              _taskData = snapshot.data == null ? [] : snapshot.data!.tasks;
              print(_taskData[0].name);
              print(_taskData[0].order);
              print(_taskData[1].order);
              _taskData.sort((a, b) => a.order.compareTo(b.order));
              print(_taskData[0].name);
              List<Widget> tasks = List<Widget>.generate(_taskData.length, (i) => _createTaskCard(context, i));
              return ReorderableColumn(
                crossAxisAlignment: CrossAxisAlignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                children: tasks,
                onReorder: (int oldIndex, int newIndex) {
                  setState(() {
                    // Remove task and add it back in appropriate position
                    TaskData task = _taskData.removeAt(oldIndex);
                    _taskData.insert(newIndex, task);
                  });
                },
                needsLongPressDraggable: false,
              );
            case ConnectionState.done:
              return const Center(
                child: Text('Connection Closed', style: TextStyle(fontSize: 30))
              );
          }
        }
      }
    );
  }
}