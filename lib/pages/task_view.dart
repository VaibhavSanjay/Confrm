import 'dart:core';
import 'package:family_tasks/Services/database.dart';
import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:intl/intl.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';

import 'Helpers/hero_dialogue_route.dart';

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
  int _selectedTask = -1; // The index of the task selected for editing, or -1 if no task is being edited
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
  late TaskData _newTask;
  final List<ColorSwatch> _availableColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green,
                                        Colors.blue, Colors.indigo, Colors.purple, Colors.grey];
  final double _editIconSize = 50;
  late final List<Reaction<Status>> _statusReactions;
  late final List<Reaction<TaskType>> _taskTypeReactions;
  final List<String> daysOfWeek = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _statusReactions = List<Reaction<Status>>.generate(
        Status.values.length,
            (int index) {
          return Reaction<Status>(
              previewIcon: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Icon(
                    _getIconForStatus(Status.values.elementAt(index)),
                    color: _getColorForStatus(Status.values.elementAt(index)),
                    size: _editIconSize/2
                )
              ),
              icon: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                    _getIconForStatus(Status.values.elementAt(index)),
                    color: _getColorForStatus(Status.values.elementAt(index)),
                    size: _editIconSize
                ),
              ),
              value: Status.values.elementAt(index)
          );
        }
    );
    _taskTypeReactions = List<Reaction<TaskType>>.generate(
        TaskType.values.length,
            (int index) {
          return Reaction<TaskType>(
              previewIcon: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: Icon(_getIconForTaskType(TaskType.values.elementAt(index)), size: _editIconSize/2)
              ),
              icon: Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(_getIconForTaskType(TaskType.values.elementAt(index)), size: _editIconSize)
              ),
              value: TaskType.values.elementAt(index)
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
                    '${_taskData[i].due.toLocal().hour}:${_taskData[i].due.toLocal().minute}'), // Due date
                trailing: ReactionButton<Status>(
                  boxPosition: Position.TOP,
                  boxElevation: 10,
                  onReactionChanged: (Status? value) {
                    _taskData[i].status = value ?? Status.inProgress;
                  },
                  initialReaction: Reaction<Status>(
                      icon: Icon(
                          _getIconForStatus(_taskData[i].status),
                          color: _getColorForStatus(_taskData[i].status),
                          size: _editIconSize
                      ),
                      value: _taskData[i].status
                      ),
                  reactions: _statusReactions,
                  boxDuration: const Duration(milliseconds: 100),
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: () {
        _newTask = TaskData.fromTaskData(_taskData.elementAt(i));
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return _createTaskEditCard(context, i);
        }));
      },
      key: ValueKey(i), // The reorderables package requires a key for each of its elements
    );
  }

  Widget _createTaskEditCard(BuildContext context, int selectedTask) {
    return Container(
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/6, left: 30, right: 30, bottom: MediaQuery.of(context).size.height/6),
        child: Hero(
          tag: selectedTask,
          child: Card(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height*2/3,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 5,
                                  child: ReactionButton<Status>(
                                    boxPosition: Position.TOP,
                                    boxElevation: 10,
                                    onReactionChanged: (Status? value) {
                                      _newTask.status = value ?? Status.inProgress;
                                    },
                                    initialReaction: Reaction<Status>(
                                        icon: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Icon(
                                              _getIconForStatus(_newTask.status),
                                              color: _getColorForStatus(_newTask.status),
                                              size: _editIconSize
                                          ),
                                        ),
                                        value: _newTask.status
                                    ),
                                    reactions: _statusReactions,
                                    boxDuration: const Duration(milliseconds: 100),
                                  ),
                                ),
                                Card(
                                  elevation: 5,
                                  child: ReactionButton<TaskType>(
                                    boxPosition: Position.TOP,
                                    boxElevation: 10,
                                    onReactionChanged: (TaskType? value) {
                                      _newTask.taskType = value ?? TaskType.other;
                                    },
                                    initialReaction: Reaction<TaskType>(
                                        icon: Container(
                                            padding: const EdgeInsets.all(10),
                                            child: Icon(_getIconForTaskType(_newTask.taskType), size: _editIconSize)
                                        ),
                                        value: _newTask.taskType
                                    ),
                                    reactions: _taskTypeReactions,
                                    boxDuration: const Duration(milliseconds: 100),
                                  ),
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      TextButton(
                                          style: TextButton.styleFrom(elevation: 5,
                                              backgroundColor: Colors.white,
                                              textStyle: const TextStyle(fontSize: 18)
                                          ),
                                          onPressed: () async {
                                            DateTime? picked = await showDatePicker(
                                                context: context,
                                                initialDate: _newTask.due.toLocal(),
                                                firstDate: DateTime(2022),
                                                lastDate: DateTime(2100));
                                            if (picked != null) {
                                              picked = picked.toUtc();
                                              setState(() {
                                                _newTask.due = DateTime((picked!).year, picked.month, picked.day, _newTask.due.hour, _newTask.due.minute);
                                              });
                                            }
                                          },
                                          child: Text('${daysOfWeek[_newTask.due.toLocal().weekday]}, '
                                              '${_newTask.due.toLocal().month}/${_newTask.due.toLocal().day}')
                                      ),
                                      TextButton(
                                          style: TextButton.styleFrom(elevation: 5,
                                              backgroundColor: Colors.white,
                                              textStyle: const TextStyle(fontSize: 18)
                                          ),
                                          onPressed: () async {
                                            TimeOfDay? picked = await showTimePicker(
                                                context: context,
                                                initialTime: TimeOfDay.fromDateTime(_newTask.due.toLocal())
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                _newTask.due = DateTime(_newTask.due.toLocal().year, _newTask.due.toLocal().month,
                                                    _newTask.due.toLocal().day, picked.hour, picked.minute).toUtc();
                                              });
                                            }
                                          },
                                          child: Text(DateFormat('h:mm a').format(_newTask.due.toLocal()))
                                      ),
                                    ]
                                )
                              ]
                          ),
                        ),
                        Container(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: TextFormField(
                                        decoration: const InputDecoration(
                                            hintText: 'Task Name',
                                            border: OutlineInputBorder(),
                                            counterText: ''
                                        ),
                                        initialValue: _newTask.name,
                                        maxLength: 30,
                                        onFieldSubmitted: (String? value) {
                                          _newTask.name = value ?? '';
                                        },
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                          hintText: 'Task Description',
                                          border: OutlineInputBorder(),
                                          counterText: ''
                                      ),
                                      initialValue: _newTask.desc,
                                      maxLength: 60,
                                      onChanged: (String? value) {
                                        _newTask.desc = value ?? '';
                                      },
                                    ),
                                  )
                                ]
                            )
                        ),
                        MaterialColorPicker(
                          selectedColor: _newTask.color,
                          allowShades: false,
                          onMainColorChange: (newColor) {
                            _newTask.color = Color.fromRGBO(newColor?.red ?? 0, newColor?.green ?? 0, newColor?.blue ?? 0, 1);
                          },
                          colors: _availableColors
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  child: const Text('Save'),
                                  onPressed: () {
                                    if (_newTask.name == '') {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Task must have a name'),
                                      ));
                                    } else {
                                      _taskData[selectedTask] = TaskData.fromTaskData(_newTask);
                                      Navigator.of(context).pop();
                                      setState((){});
                                    }
                                  }
                              ),
                              TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }
                              )
                            ]
                        ),
                      ]
                  ),
                ),
              )
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    /* This widget is rebuilt on every reorder.
       So we must remake the list of task cards based on the list of task data.
     */
    List<Widget> tasks = List<Widget>.generate(_taskData.length, (i) => _createTaskCard(context, i));
    tasks.add(
      StreamBuilder<FamilyTaskData>(
        key: ValueKey(100),
        stream: DatabaseService('100').taskDataForFamily,
        builder: (context, AsyncSnapshot<FamilyTaskData> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return Text(snapshot.data!.name);
          } else {
            return const Text('Loading');
          }
        }
      )
    );

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
  }
}