import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reorderables/reorderables.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';

enum TaskType {
  Garbage,
  Shopping,
  Cooking,
  Cleaning,
  Other
}

// A class to represent the data for a task
class TaskData {
  TaskData({required this.name, required this.taskType, this.desc});

  String name; // User provided name for a task
  TaskType taskType; // User provided type of task
  String? desc; // User provided task description (optional)
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
  int selectedTask = -1; // The index of the task selected for editing, or -1 if no task is being edited
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
  late TextEditingController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
    List<Widget> tasks = _taskData.asMap().map((i, data) => MapEntry(i,
        InkWell(
          child: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: Icon(_getIcon(data.taskType)), // Put the icon for the type of task
                  title: Text(data.name), // Name of task
                  subtitle: Text(data.desc ?? ''), // Description if not null, otherwise nothing
                ),
              ],
            ),
          ),
          onTap: () {
            setState(() {
              selectedTask = i; // When this card is tapped, make the editor show up for its index
            });
          },
          key: ValueKey(i), // The reorderables package requires a key for each of its elements
        )
    )).values.toList();

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
              opacity: selectedTask >= 0 ? 0.5: 1, // Make transparent if Task is being edited
              child: col
            ),
            alignment: Alignment.topCenter
          ),
          // Make editing card if task is being edited, or else just make an empty widget
          selectedTask >= 0 ? Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
            child: Card(
                child: Column(
                    children:
                    [
                      ListTile(
                        leading: ReactionButton<TaskType>(
                          boxPosition: Position.TOP,
                          boxElevation: 10,
                          onReactionChanged: (TaskType? value) {
                            print('Selected value: $value');
                          },
                          reactions: List<Reaction<TaskType>>.generate(
                            TaskType.values.length,
                            (int index) {
                              return Reaction<TaskType>(
                                  icon: Container(
                                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                    child: Icon(_getIcon(TaskType.values.elementAt(index)))
                                  ),
                                  value: TaskType.values.elementAt(index)
                              );
                            }
                          )
                        ),
                        title: TextFormField(
                            initialValue: _taskData[selectedTask].name,
                            onFieldSubmitted: (String? value) {
                              _taskData[selectedTask].name = value!;
                            },
                        ),
                        subtitle: TextFormField(
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 3,
                          initialValue: _taskData[selectedTask].desc ?? '',
                          onChanged: (String? value) {
                            _taskData[selectedTask].desc = value;
                          },
                        ),
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