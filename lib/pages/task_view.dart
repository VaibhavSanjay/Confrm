import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

enum TaskType {
  Garbage,
  Shopping,
  Cooking,
  Cleaning,
  Other
}

// A class to represent the data for a task
class TaskData {
  late String name; // User provided name for a task
  late TaskType taskType; // User provided type of task
  late String desc; // User provided task description (optional)
  late Color color;

  TaskData({this.name = '', this.taskType = TaskType.Other, this.desc = '', this.color = Colors.white});

  TaskData.fromTaskData(TaskData td) {
    name = td.name;
    taskType = td.taskType;
    desc = td.desc;
    color = td.color;
  }

}

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
        taskType: TaskType.Cleaning,
        desc: 'Please clean the sink'
    ),
    TaskData(
        name: "Take out trash",
        taskType: TaskType.Garbage,
        color: Colors.red
    ),
    TaskData(
        name: "Cook",
        taskType: TaskType.Cooking,
        desc: 'Food',
        color: Colors.purple
    ),
  ];
  late TaskData _newTask;
  bool _badData = false;
  final List<Color> _availableColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green,
                                        Colors.blue, Colors.indigo, Colors.purple, Colors.grey];
  final double _iconSize = 45;

  // A helper function to get the icon data based on a task type
  IconData _getIcon(TaskType tt) {
    switch (tt) {
      case TaskType.Garbage:
        return FontAwesomeIcons.trash;
      case TaskType.Cleaning:
        return FontAwesomeIcons.broom;
      case TaskType.Cooking:
        return FontAwesomeIcons.utensils;
      case TaskType.Shopping:
        return FontAwesomeIcons.cartShopping;
      case TaskType.Other:
        return FontAwesomeIcons.star;
    }
  }

  Widget _createTaskCard(int i) {
    return InkWell(
      child: Card(
        color: _taskData[i].color,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(_getIcon(_taskData[i].taskType)), // Put the icon for the type of task
              title: Text(_taskData[i].name), // Name of task
              subtitle: Text(_taskData[i].desc), // Description of task
            ),
          ],
        ),
      ),
      onTap: () {editTask(i);},
      key: ValueKey(i), // The reorderables package requires a key for each of its elements
    );
  }

  // Causes the edit menu to pop up for a task with a given index. If index < 0 then a new task is created.
  void editTask(int index) {
    if (index >= 0) {
      setState(() {
        _selectedTask = index;
        _newTask = TaskData.fromTaskData(_taskData.elementAt(index));
      });
    } else {
      setState(() {
        _selectedTask = _taskData.length;
        _newTask = TaskData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Function called when the user reorders the tasks
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        // Remove task and add it back in appropriate position
        TaskData task = _taskData.removeAt(oldIndex);
        _taskData.insert(newIndex, task);
      });
    }

    /* This widget is rebuilt on every reorder.
       So we must remake the list of task cards based on the list of task data.
     */
    List<Widget> tasks = List<Widget>.generate(_taskData.length, _createTaskCard);

    ReorderableColumn col = ReorderableColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: tasks,
        onReorder: _onReorder,
        needsLongPressDraggable: false,
    );
    return Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: [
          Container(
            child: Opacity(
              opacity: _selectedTask >= 0 ? 0.5: 1, // Make transparent if Task is being edited
              child: col
            ),
            alignment: Alignment.topCenter
          ),
          // Make editing card if task is being edited, or else just make an empty widget
          _selectedTask >= 0 ? Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
            child: Card(
                child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
                            child: Card(
                              shape: const CircleBorder(),
                              child: ReactionButton<TaskType>(
                                  boxPosition: Position.TOP,
                                  boxElevation: 10,
                                  onReactionChanged: (TaskType? value) {
                                    _newTask.taskType = value ?? TaskType.Other;
                                  },
                                  initialReaction: Reaction<TaskType>(
                                      icon: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                          child: Icon(_getIcon(_newTask.taskType), size: _iconSize)
                                      ),
                                      value: _newTask.taskType
                                  ),
                                  reactions: List<Reaction<TaskType>>.generate(
                                      TaskType.values.length,
                                          (int index) {
                                        return Reaction<TaskType>(
                                            icon: Container(
                                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                                child: Icon(_getIcon(TaskType.values.elementAt(index)), size: _iconSize)
                                            ),
                                            value: TaskType.values.elementAt(index)
                                        );
                                      }
                                  ),
                                  boxDuration: const Duration(milliseconds: 100),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: TextFormField(
                                      initialValue: _newTask.name,
                                      onFieldSubmitted: (String? value) {
                                        _newTask.name = value ?? '';
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5, height: 5),
                                  Flexible(
                                    flex: 1,
                                    child: TextFormField(
                                      initialValue: _newTask.desc,
                                      onChanged: (String? value) {
                                        _newTask.desc = value ?? '';
                                      },
                                    ),
                                  )
                                ]
                            )
                          )
                        ]
                      ),
                      Flexible(
                        child: BlockPicker(
                            pickerColor: _newTask.color,
                            onColorChanged: (Color newColor) {
                              _newTask.color = newColor;
                            },
                            availableColors: _availableColors
                        ),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                child: const Text('Save'),
                                onPressed: () {
                                  if (_newTask.name == '') {
                                    setState(() {
                                      _badData = true;
                                    });
                                  } else {
                                    setState(() {
                                      _taskData[_selectedTask] = TaskData.fromTaskData(_newTask);
                                      _selectedTask = -1;
                                      _badData = false;
                                    });
                                  }
                                }
                            ),
                            TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  setState(() {
                                    _selectedTask = -1;
                                  });
                                }
                            )
                          ]
                      ),
                      !_badData ? const SizedBox.shrink() : const ListTile(
                        leading: Icon(Icons.warning),
                        title: Text('Invalid Name'),
                        subtitle: Text('Please assign a name to this task.'),
                      )
                    ]
                )
            )
          ):
          const SizedBox.shrink()
        ]
    );
  }
}