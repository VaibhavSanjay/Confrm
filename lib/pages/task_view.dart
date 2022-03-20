import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum TaskType {
  Garbage,
  Shopping,
  Cooking,
  Cleaning,
  Other
}

class TaskData {
  TaskData({required this.name, required this.taskType, this.desc});

  String name;
  TaskType taskType;
  String? desc;
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
  late List<Widget> _tasks;
  int selectedTask = -1;
  List<TaskData> _taskData = [
    TaskData(
        name: "Clean Sink",
        taskType: TaskType.Cleaning,
        desc: 'Please clean the sink'
    ),
    TaskData(
        name: "Take out trash",
        taskType: TaskType.Garbage,
        desc: 'Garbage'
    ),
    TaskData(
        name: "Cook",
        taskType: TaskType.Cooking,
        desc: 'Food'
    ),
  ];

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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    void _onReorder(int oldIndex, int newIndex) {
      setState(() {
        TaskData task = _taskData.removeAt(oldIndex);
        _taskData.insert(newIndex, task);
      });
    }

    _tasks = _taskData.asMap().map((i, data) => MapEntry(i,
        InkWell(
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(_getIcon(data.taskType)),
                  title: Text(data.name),
                  subtitle: Text(data.desc ?? ''),
                ),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              selectedTask = i - 1;
            });
          },
          key: ValueKey(i++),
        )
    )).values.toList();

    ReorderableColumn col = ReorderableColumn(
        crossAxisAlignment: CrossAxisAlignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        children: _tasks,
        onReorder: _onReorder,
        needsLongPressDraggable: false,
    );
    return Stack(
        alignment: AlignmentDirectional.center,
        fit: StackFit.expand,
        children: [
          Container(
            child: Opacity(
              opacity: selectedTask >= 0 ? 0.5: 1,
              child: col
            ),
            alignment: Alignment.topCenter
          ),
          selectedTask >= 0 ? Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
            child: Card(
                child: Column(
                    children:
                    [
                      ListTile(
                        leading: Icon(_getIcon(_taskData[selectedTask].taskType)),
                        title: TextFormField(
                            initialValue: _taskData[selectedTask].name,
                            onFieldSubmitted: (String? value) {
                              _taskData[selectedTask].name = value!;
                            },
                            validator: (String? value) {
                              return value == null ? 'Name cannot be empty' : null;
                            },
                        ),
                        subtitle: Text(_taskData[selectedTask].desc ?? ''),
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                child: const Text('Cancel'),
                                onPressed: () {
                                  setState(() {
                                    selectedTask = -1;
                                  });
                                }
                            )
                          ]
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