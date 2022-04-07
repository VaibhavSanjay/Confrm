import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/family_task_data.dart';
import 'constants.dart';

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

class EditTaskData extends StatefulWidget {
  final int selectedTask;
  final EdgeInsets padding;
  final TaskData taskData;
  final void Function(TaskData?) onExit;

  const EditTaskData({Key? key, required this.selectedTask, required this.taskData,
                      this.padding = const EdgeInsets.all(0), required this.onExit}) : super(key: key);

  @override
  State<EditTaskData> createState() => _EditTaskDataState();
}

class _EditTaskDataState extends State<EditTaskData> {
  final double _editIconSize = 50;
  late TaskData _newTask;
  late final List<Reaction<Status>> _statusReactions;
  late final List<Reaction<TaskType>> _taskTypeReactions;

  @override
  void initState() {
    super.initState();
    _newTask = TaskData.fromTaskData(widget.taskData);

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

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: widget.padding,
        child: Hero(
          tag: widget.selectedTask,
          child: Card(
              child: AnimatedContainer(
                decoration: BoxDecoration(
                  border: Border.all(color: _newTask.color, width: 5)
                ),
                duration: const Duration(milliseconds: 200),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SingleChildScrollView(
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
                                      Column(
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
                                          Container(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: const Text('Progress', style: TextStyle(fontSize: 18))
                                          )
                                        ],
                                      ),
                                      Column(
                                        children: [
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
                                          Container(
                                            padding: const EdgeInsets.only(top: 5),
                                            child: const Text('Type', style: TextStyle(fontSize: 18))
                                          )
                                        ],
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
                                              onChanged: (String? value) {
                                                _newTask.name = value ?? '';
                                              },
                                            ),
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 10),
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
                                          ),
                                        ),
                                        Flexible(
                                          fit: FlexFit.loose,
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 10),
                                            child: TextFormField(
                                              decoration: const InputDecoration(
                                                  hintText: 'Location',
                                                  border: OutlineInputBorder(),
                                                  counterText: ''
                                              ),
                                              initialValue: _newTask.location,
                                              maxLength: 30,
                                              onChanged: (String? value) {
                                                _newTask.location = value ?? '';
                                              },
                                            ),
                                          ),
                                        ),
                                      ]
                                  )
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 40),
                                child: MaterialColorPicker(
                                    physics: const NeverScrollableScrollPhysics(),
                                    selectedColor: _newTask.color,
                                    allowShades: false,
                                    onMainColorChange: (newColor) {
                                      setState(() {
                                        _newTask.color = newColor ?? Colors.grey;
                                      });
                                    },
                                    colors: availableColors
                                ),
                              ),
                            ]
                        ),
                      ),
                    ),
                    Container(
                      color: Colors.white,
                      child: Row(
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
                                    widget.onExit(_newTask);
                                  }
                                }
                            ),
                            TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  widget.onExit(widget.taskData);
                                }
                            ),
                            TextButton(
                                onPressed: () async {
                                  showDialog<void>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                            title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.bold)),
                                            content: const Text('Are you sure you want to delete this task?'),
                                            actions: [
                                              TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: const Text('Cancel')
                                              ),
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    widget.onExit(null);
                                                  },
                                                  child: const Text('Delete')
                                              )
                                            ]
                                        );
                                      }
                                  );
                                },
                                child: const Text('Delete')
                            )
                          ]
                      ),
                    ),
                  ],
                ),
              )
          ),
        )
    );
  }
}

class ArchiveTaskData extends StatefulWidget {
  final EdgeInsets padding;
  final void Function(int) onUnarchive;
  final void Function(int) onDelete;
  final List<TaskData> archivedTasks;
  final Stream<FamilyTaskData> stream;
  final void Function() onClean;

  const ArchiveTaskData({Key? key, this.padding = const EdgeInsets.all(0),
    required this.archivedTasks, required this.onUnarchive, required this.onDelete,
    required this.stream, required this.onClean}) : super(key: key);

  @override
  State<ArchiveTaskData> createState() => _ArchiveTaskDataState();
}

class _ArchiveTaskDataState extends State<ArchiveTaskData> {
  late List<TaskData> _taskData;

  @override
  void initState() {
    super.initState();
    _taskData = widget.archivedTasks;
  }

  @override
  Widget build(BuildContext context) {
    Widget _buildList() {
      return MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: _taskData.length,
          itemBuilder: (BuildContext context, int i) {
            return Card(
              elevation: 5,
              color: _taskData[i].color,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                      leading: Icon(_getIconForTaskType(_taskData[i].taskType)), // Put the icon for the type of task
                      title: Text(_taskData[i].name), // Name of task
                      subtitle: Text('Completed: ${daysOfWeek[_taskData[i].archived.toLocal().weekday]}, '
                          '${DateFormat('h:mm a').format(_taskData[i].archived.toLocal())}'), // Due date
                      trailing: ReactionButton<String>(
                        boxPosition: Position.BOTTOM,
                        boxElevation: 10,
                        onReactionChanged: (String? value) {
                          if (value == 'unarchive') {
                            widget.onUnarchive(i);
                          } else if (value == 'delete') {
                            widget.onDelete(i);
                          }
                        },
                        initialReaction: Reaction<String>(
                            icon: const Icon(Icons.more_vert),
                            value: 'edit'
                        ),
                        reactions: [
                          Reaction<String>(
                              previewIcon: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  child: const Icon(Icons.outbox, size: 30)
                              ),
                              icon: const SizedBox.shrink(),
                              value: 'unarchive'
                          ),
                          Reaction<String>(
                              previewIcon: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                  child: const Icon(Icons.delete_forever, size: 30)
                              ),
                              icon: const SizedBox.shrink(),
                              value: 'delete'
                          )
                        ],
                        boxDuration: const Duration(milliseconds: 100),
                      ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Container(
      padding: widget.padding,
      child: Hero(
        tag: 'archive',
        child: Card(
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 20),
                      child: const Text('Archived', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 40))
                    ),
                    TextButton(
                      style: TextButton.styleFrom(elevation: 5,
                          backgroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 18)
                      ),
                      child: const Text('Clean'),
                      onPressed: widget.onClean
                    ),
                    StreamBuilder<FamilyTaskData>(
                      stream: widget.stream,
                      initialData: FamilyTaskData(archive: widget.archivedTasks),
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
                              return const Center(
                                  child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(),
                                  )
                              );
                            case ConnectionState.waiting:
                              return _buildList();
                            case ConnectionState.active:
                              _taskData = snapshot.data == null ? [] : snapshot.data!.archive;
                              return _buildList();
                            case ConnectionState.done:
                              return const Center(
                                  child: Text('Connection Closed', style: TextStyle(fontSize: 30))
                              );
                          }
                        }
                      }
                    )
                  ]
              ),
            )
        ),
      )
    );
  }
}

