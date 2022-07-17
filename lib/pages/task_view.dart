import 'dart:core';
import 'package:family_tasks/Services/authentication.dart';
import 'package:family_tasks/Services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:reorderables/reorderables.dart';
import 'package:family_tasks/models/family_task_data.dart';

import '../models/user_data.dart';
import 'Helpers/constants.dart';
import 'Helpers/hero_dialogue_route.dart';
import 'Helpers/task_view_cards.dart';

class TaskViewPage extends StatefulWidget {
  const TaskViewPage({Key? key, required this.famID}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final String famID;

  @override
  State<TaskViewPage> createState() => TaskViewPageState();
}

class TaskViewPageState extends State<TaskViewPage> {
  List<TaskData> _taskData = []; // Hold all the task data
  List<TaskData> _archivedTaskData = []; // Hold all the archive data
  Map<String, UserData> _users = {};
  late DatabaseService ds = DatabaseService(widget.famID); // Get data from Database
  late Stream<FamilyTaskData> stream = ds.taskDataForFamily; // Put data in the stream
  AuthenticationService auth = AuthenticationService();
  bool _menuOpen = false;
  bool _filter = false, _sorting = false;

  // When user adds a new task
  Future<bool> _addTask() async {
    // Maximum of MAX_TASKS
    if (_taskData.length >= maxTasks) {
      return false;
    }

    Navigator.of(context).push(HeroDialogRoute(builder: (context) {
      return EditTaskData(
          selectedTask: false,
          taskData: TaskData(),
          users: _users,
          padding: EdgeInsets.only(top: MediaQuery.of(context).size.height/6, left: 30, right: 30, bottom: MediaQuery.of(context).size.height/6),
          onExit: (TaskData? data) async {
            if (data != null) {
              // Non-null means task data was saved.
              _taskData.add(TaskData.fromTaskData(data));
              ds.updateTaskData(_taskData);
            }

            Navigator.of(context).pop();
            setState((){});
          }
      );
    }));

    return true;
  }

  void _archiveTask(int index) {
    if (index >= 0) {
      _archivedTaskData.add(_taskData.removeAt(index)
        ..archived = DateTime.now().toUtc()
        ..completedBy = auth.id!
      );
      // Remove the earliest completed task if more than MAX_TASKS archived
      if (_archivedTaskData.length > maxTasks) {
        _archivedTaskData.removeAt(0);
      }
      ds.updateTaskData(_taskData);
      ds.updateArchiveData(_archivedTaskData);
    }
  }

  Widget _createArchiveCardList(EdgeInsets padding) {
    return ArchiveTaskData(
        padding: padding,
        archivedTasks: _archivedTaskData,
        onUnarchive: (int i) {
          // Add task back to regular task list and change archive date to 2101
          _taskData.add(_archivedTaskData.removeAt(i)..archived = DateTime(2101));
          ds.updateTaskData(_taskData);
          ds.updateArchiveData(_archivedTaskData);
        },
        onDelete: (int i) {
          _archivedTaskData.removeAt(i);
          ds.updateArchiveData(_archivedTaskData);
        },
        stream: stream,
        users: _users,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FamilyTaskData>(
      // Build stream for Family Task Data
        stream: stream,
        builder: (context, AsyncSnapshot<FamilyTaskData> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
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
                if (_taskData.isEmpty) {
                  return const Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      )
                  );
                } else {
                  // If we have task data, we just list it instead of loading
                  List<Widget> tasks = List<Widget>.generate(_taskData.length, (i) => TaskCard(
                    number: i,
                    taskData: _taskData[i],
                    users: _users,
                    onComplete: () => _archiveTask(i),
                    onDelete: () {
                      _taskData.removeAt(i);
                      ds.updateTaskData(_taskData);
                    },
                    onEditComplete: (TaskData? data) async {
                      if (data != null) {
                        // Non-null means task data was saved.
                        _taskData[i] = TaskData.fromTaskData(data);
                        await ds.updateTaskData(_taskData);
                      } else {
                        // Null means task was deleted
                        _taskData.removeAt(i);
                        ds.updateTaskData(_taskData);
                      }

                      Navigator.of(context).pop();
                      setState((){});
                    },
                  ));
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: tasks,
                    ),
                  );
                }
              case ConnectionState.active:
                _taskData = snapshot.data == null ? [] : snapshot.data!.tasks;

                int i = 0;
                List<List> shownTaskData = _taskData.map((td) => [td, i++]).toList();
                if (_filter) {
                  shownTaskData = shownTaskData.where((item) => item[0].assignedUsers.contains(auth.id!)).toList();
                }
                if (_sorting) {
                  shownTaskData.sort((a, b) => a[0].due.compareTo(b[0].due));
                }

                _archivedTaskData = snapshot.data == null ? [] : snapshot.data!.archive;
                _users = snapshot.data == null ? {} : snapshot.data!.users;
                List<Widget> tasks = List<Widget>.generate(shownTaskData.length, (i) => TaskCard(
                  key: ValueKey(i),
                  number: i,
                  taskData: shownTaskData[i][0],
                  users: _users,
                  onComplete: () => _archiveTask(shownTaskData[i][1]),
                  onDelete: () {
                    _taskData.removeAt(shownTaskData[i][1]);
                    ds.updateTaskData(_taskData);
                  },
                  onEditComplete: (TaskData? data) async {
                    if (data != null) {
                      // Non-null means task data was saved.
                      _taskData[shownTaskData[i][1]] = TaskData.fromTaskData(data);
                      await ds.updateTaskData(_taskData);
                    } else {
                      // Null means task was deleted
                      _taskData.removeAt(shownTaskData[i][1]);
                      ds.updateTaskData(_taskData);
                    }

                    Navigator.of(context).pop();
                    setState((){});
                  },
                ));

                return ReorderableColumn(
                  scrollController: ScrollController(),
                  header: AnimatedContainer(
                    padding: EdgeInsets.only(bottom: _menuOpen ? 15: 5),
                    duration: const Duration(milliseconds: 150),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AnimatedOpacity(
                            opacity: _menuOpen ? 0 : 1,
                            duration: const Duration(milliseconds: 300),
                            child: const Text('Your Tasks', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))
                        ),
                        SpeedDial(
                          animationSpeed: 225,
                          switchLabelPosition: true,
                          child: const Icon(FontAwesomeIcons.caretLeft, color: Colors.white),
                          spaceBetweenChildren: 15,
                          activeChild: const Icon(FontAwesomeIcons.caretRight, color: Colors.white),
                          overlayOpacity: 0,
                          direction: SpeedDialDirection.left,
                          heroTag: 'archive',
                          onOpen: () => setState(() {_menuOpen = true;}),
                          onClose: () => setState(() {_menuOpen = false;}),
                          children: [
                            SpeedDialChild(
                                labelWidget: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold),),
                                elevation: (_filter || _sorting) ? 0 : null,
                                child: Icon(Icons.add, color: Colors.white.withOpacity((_filter || _sorting) ? 0.5 : 1)),
                                backgroundColor: Colors.lightBlue.withOpacity((_filter || _sorting) ? 0.5 : 1),
                                onTap: () async {
                                  if (!(_filter || _sorting) && !(await _addTask())) {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                        content: Text('Maximum of 20 tasks reached.')
                                    ));
                                  }
                                }
                            ),
                            SpeedDialChild(
                                labelWidget: const Text('Archive', style: TextStyle(fontWeight: FontWeight.bold),),
                                child: const Icon(Icons.inbox, color: Colors.white),
                                backgroundColor: Colors.blue,
                                onTap: () async {
                                  Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                                    return _createArchiveCardList(
                                        EdgeInsets.only(top: MediaQuery.of(context).size.height / 6, left: 30, right: 30,
                                            bottom: MediaQuery.of(context).size.height / 6
                                        )
                                    );
                                  }));
                                }
                            ),
                            SpeedDialChild(
                                labelWidget: const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold),),
                                child: Icon(_filter ? Icons.filter_list_off : Icons.filter_list, color: Colors.white),
                                backgroundColor: Colors.blueAccent,
                                onTap: () => setState(() {_filter = !_filter;})
                            ),
                            SpeedDialChild(
                                labelWidget: const Text('Sort', style: TextStyle(fontWeight: FontWeight.bold),),
                                child: Icon(_sorting ? Icons.cancel : Icons.sort, color: Colors.white),
                                backgroundColor: Colors.indigoAccent,
                                onTap: () => setState(() {_sorting = !_sorting;})
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  crossAxisAlignment: CrossAxisAlignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  children: tasks.isNotEmpty ? tasks : [const Padding(
                    key: ValueKey(0),
                    padding: EdgeInsets.all(10),
                    child: Text('You have no assigned tasks.', style: TextStyle(color: Colors.grey, fontSize: 18, fontWeight: FontWeight.bold))
                  )],
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      // Remove task and add it back in appropriate position
                      TaskData task = _taskData.removeAt(oldIndex);
                      _taskData.insert(newIndex, task);
                      ds.updateTaskData(_taskData);
                    });
                  },
                  needsLongPressDraggable: true,
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