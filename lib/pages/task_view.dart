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
  bool _filter = false;

  // When user adds a new task
  Future<bool> _addTask() async {
    // Maximum of MAX_TASKS
    if (_taskData.length >= maxTasks) {
      return false;
    }
    _taskData.add(TaskData());
    await ds.updateTaskData(_taskData); // Send data to Firebase
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
        onClean: () {
          // Delete tasks that are over an hour old
          DateTime hourAgo = DateTime.now().toUtc().subtract(const Duration(hours: 1));
          _archivedTaskData = _archivedTaskData.where((td) => td.archived.isAfter(hourAgo)).toList();
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
                if (_filter) {
                  _taskData = _taskData.where((item) => item.assignedUsers.contains(auth.id!)).toList();
                }
                _archivedTaskData = snapshot.data == null ? [] : snapshot.data!.archive;
                _users = snapshot.data == null ? {} : snapshot.data!.users;
                List<Widget> tasks = List<Widget>.generate(_taskData.length, (i) => TaskCard(
                  key: ValueKey(i),
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

                return ReorderableColumn(
                  scrollController: ScrollController(),
                  header: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedOpacity(
                          opacity: _menuOpen ? 0 : 1,
                          duration: const Duration(milliseconds: 150),
                          child: const Text('Your Tasks', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold))
                      ),
                      SpeedDial(
                        child: const Icon(FontAwesomeIcons.caretLeft, color: Colors.white),
                        activeChild: const Icon(FontAwesomeIcons.caretRight, color: Colors.white),
                        overlayOpacity: 0,
                        direction: SpeedDialDirection.left,
                        heroTag: 'archive',
                        onOpen: () => setState(() {_menuOpen = true;}),
                        onClose: () => setState(() {_menuOpen = false;}),
                        children: [
                          SpeedDialChild(
                              elevation: _filter ? 0 : null,
                              child: Icon(Icons.add, color: Colors.white.withOpacity(_filter ? 0.5 : 1)),
                              backgroundColor: Colors.red.withOpacity(_filter ? 0.5 : 1),
                              onTap: () async {
                                if (!_filter && !(await _addTask())) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                      content: Text('Maximum of 20 tasks reached.')
                                  ));
                                }
                              }
                          ),
                          SpeedDialChild(
                              child: const Icon(Icons.inbox, color: Colors.white),
                              backgroundColor: Colors.orange,
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
                              child: Icon(_filter ? Icons.filter_list_off : Icons.filter_list),
                              backgroundColor: Colors.green,
                              onTap: () => setState(() {_filter = !_filter;})
                          )
                        ],
                      )
                    ],
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