import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/family_task_data.dart';

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
  final List<String> daysOfWeek = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  late TaskData _newTask;
  late final List<Reaction<Status>> _statusReactions;
  late final List<Reaction<TaskType>> _taskTypeReactions;
  final List<ColorSwatch> _availableColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green,
    Colors.blue, Colors.indigo, Colors.purple, Colors.grey];

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
                              _newTask.color = newColor ?? Colors.grey;
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
                                      widget.onExit(_newTask);
                                    }
                                  }
                              ),
                              TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {
                                    widget.onExit(null);
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
}
