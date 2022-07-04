import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_reaction_button/flutter_reaction_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';

import '../../Services/place_service.dart';
import '../../models/family_task_data.dart';
import '../../models/user_data.dart';
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
  final Map<String, UserData> users;
  final void Function(TaskData?) onExit;

  const EditTaskData({Key? key, required this.selectedTask, required this.taskData,
                      this.padding = const EdgeInsets.all(0), required this.onExit,
                      required this.users}) : super(key: key);

  @override
  State<EditTaskData> createState() => _EditTaskDataState();
}

class _EditTaskDataState extends State<EditTaskData> {
  final double _editIconSize = 50;
  late TaskData _newTask;
  late Map<String, List> _users;
  late final List<Reaction<Status>> _statusReactions;
  late final List<Reaction<TaskType>> _taskTypeReactions;
  final TextEditingController _textController = TextEditingController();
  final CustomPopupMenuController _controller = CustomPopupMenuController();

  @override
  void initState() {
    super.initState();
    _newTask = widget.taskData;
    _users = widget.users.map((key, value) => MapEntry(key, [value, true]));
    _textController.text = _newTask.location;

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
  void dispose() {
    super.dispose();
    _textController.dispose();
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            fit: FlexFit.loose,
                                            child: Container(
                                              child: TextFormField(
                                                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                                decoration: const InputDecoration(
                                                  isDense: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                  enabledBorder: OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                                                  ),
                                                  hintText: 'Name',
                                                  //border: OutlineInputBorder(),
                                                  counterText: '',
                                                  border: OutlineInputBorder(),
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
                                                keyboardType: TextInputType.multiline,
                                                minLines: 1,
                                                maxLines: 2,
                                                decoration: const InputDecoration(
                                                    isDense: true,
                                                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                                    enabledBorder: OutlineInputBorder(
                                                      // width: 0.0 produces a thin "hairline" border
                                                      borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                                                    ),
                                                    hintText: 'Description',
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
                                        ]
                                    ),
                                  ),
                                  const VerticalDivider(width: 10),
                                  SizedBox(
                                    width: 110,
                                    height: 100,
                                    child: CustomPopupMenu(
                                      controller: _controller,
                                      pressType: PressType.singleClick,
                                      barrierColor: Colors.transparent,
                                      child: Builder(
                                          builder: (context) {
                                            // Get all UserData for those doing the task
                                            List taskUsers = _users.values.where((item) => item[1]).map((item) => item[0]).toList();
                                            int length = min(taskUsers.length, 3);
                                            return taskUsers.isEmpty ? const Icon(Icons.add_circle_outline, size: 85) :
                                            Stack(
                                              alignment: Alignment.centerRight,
                                              children: List.generate(
                                                  length,
                                                      (index) => Positioned(
                                                    top: 5,
                                                    left: index * 22 + (20 - 7*length.toDouble()),
                                                    child: CircleAvatar(
                                                        radius: 35,
                                                        backgroundColor: Colors.grey,
                                                        child: Text(
                                                          taskUsers[index].initials,
                                                          style: const TextStyle(fontSize: 35, color: Colors.white),
                                                          overflow: TextOverflow.fade, softWrap: false,
                                                        )
                                                    ),
                                                  )
                                              ),
                                            );
                                          }
                                      ),
                                      menuBuilder: () {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: Container(
                                            color: const Color(0xFF4C4C4C),
                                            child: GridView.count(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                                crossAxisCount: 5,
                                                crossAxisSpacing: 0,
                                                mainAxisSpacing: 10,
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                children: _users.map(
                                                        (key, value) => MapEntry(
                                                        key,
                                                        SizedBox(
                                                          width: 60,
                                                          child: InkWell(
                                                            onTap: () {
                                                              _users[key] = [value[0], !value[1]];
                                                              _controller.hideMenu();
                                                              _controller.showMenu();
                                                              setState(() {});
                                                            },
                                                            child: Column(
                                                              children: [
                                                                Stack(
                                                                    alignment: Alignment.center,
                                                                    children: [
                                                                      CircleAvatar(
                                                                          radius: 20,
                                                                          backgroundColor: Colors.grey,
                                                                          child: Text(value[0].initials, style: const TextStyle(fontSize: 20, color: Colors.white), overflow: TextOverflow.fade, softWrap: false,)
                                                                      ),
                                                                      value[1] ? const Icon(Icons.check_sharp, color: Colors.green, size: 25) : const SizedBox.shrink()
                                                                    ]
                                                                ),
                                                                const Divider(
                                                                    height: 5
                                                                ),
                                                                Text(value[0].name, style: const TextStyle(fontSize: 8, color: Colors.white), overflow: TextOverflow.ellipsis)
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                    )
                                                ).values.toList()
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
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
                                                  enabledBorder: OutlineInputBorder(
                                                    // width: 0.0 produces a thin "hairline" border
                                                    borderSide: BorderSide(color: Colors.transparent, width: 0.0),
                                                  ),
                                                  hintText: 'Task Name',
                                                  //border: OutlineInputBorder(),
                                                  counterText: '',
                                                  border: OutlineInputBorder(),
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
                                              controller: _textController,
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                  hintText: 'Location',
                                                  border: OutlineInputBorder(),
                                                  counterText: ''
                                              ),
                                              onTap: () async {
                                                String sessionToken = const Uuid().v4();
                                                Suggestion? result = await showSearch(
                                                  context: context,
                                                  delegate: AddressSearch(sessionToken),
                                                  query: _newTask.location
                                                );
                                                if (result != null) {
                                                  List<double> loc = await PlaceApiProvider(sessionToken)
                                                      .getPlaceDetailFromId(result.placeId);
                                                  _newTask.location = result.description;
                                                  _textController.text = result.description;
                                                  _newTask.coords = loc;
                                                }
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
  final Map<String, UserData> users;
  final Stream<FamilyTaskData> stream;
  final void Function() onClean;

  const ArchiveTaskData({Key? key, this.padding = const EdgeInsets.all(0),
    required this.archivedTasks, required this.onUnarchive, required this.onDelete,
    required this.stream, required this.onClean, required this.users}) : super(key: key);

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
                  leading: CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey,
                    child: Text(widget.users[_taskData[i].completedBy]?.initials ?? '',
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                      overflow: TextOverflow.fade, softWrap: false,)
                  ), // Put the icon for the type of task
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

  @override
  Widget build(BuildContext context) {
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

class AddressSearch extends SearchDelegate<Suggestion> {
  AddressSearch(this.sessionToken) {
    apiClient = PlaceApiProvider(sessionToken);
  }

  final String sessionToken;
  late PlaceApiProvider apiClient;

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildSuggestions(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<Suggestion>>(
      // We will put the api call here
      future: query == ""
          ? null
          : apiClient.fetchSuggestions(
          query, Localizations.localeOf(context).languageCode),
      builder: (context, snapshot) => query == ''
          ? Container(
        padding: const EdgeInsets.all(16.0),
        child: const Text('Enter a Location.', style: TextStyle(color: Colors.grey, fontSize: 20),),
      )
          : snapshot.hasData
          ? ListView.builder(
        itemBuilder: (context, index) => Card(
          child: ListTile(
            // we will display the data returned from our future here
            title:
            Text(snapshot.data![index].description),
            onTap: () {
              close(context, snapshot.data![index]);
            },
          ),
        ),
        itemCount: snapshot.data!.length,
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class UserPicker extends StatefulWidget {
  const UserPicker({Key? key, required this.userPicked}) : super(key: key);

  final Map<String, List> userPicked;

  @override
  State<UserPicker> createState() => _UserPickerState();
}

class _UserPickerState extends State<UserPicker> {
  late Map<String, List> _userPicked = widget.userPicked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Wrap(
          spacing: 10,
          children: _userPicked.map(
                  (key, value) => MapEntry(
                  key,
                  SizedBox(
                    width: 60,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _userPicked[key] = [value[0], !value[1]];
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey,
                              child: Text(value[0].initials, style: const TextStyle(fontSize: 30, color: Colors.white), overflow: TextOverflow.fade, softWrap: false,)
                          ),
                          value[1] ? const Icon(Icons.check, color: Colors.green, size: 25) : const SizedBox.shrink()
                        ]
                      ),
                    ),
                  )
              )
          ).values.toList()
      ),
    );
  }
}


