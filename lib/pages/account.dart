import 'package:family_tasks/Services/location_callback.dart';
import 'package:family_tasks/pages/Helpers/account_option_widgets.dart';
import 'package:family_tasks/pages/Helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../Services/database.dart';
import '../models/family_task_data.dart';
import 'Helpers/account_card.dart';
import 'Helpers/hero_dialogue_route.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required this.famID, required this.onLeave, required this.onLocationSetting}) : super(key: key);

  final String famID;
  final Function() onLeave;
  final Function(bool) onLocationSetting;

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  static bool _locationEnabled = false;
  late DatabaseService ds = DatabaseService(widget.famID);
  String _input = '';
  final _formKey = GlobalKey<FormState>();
  bool _showID = false;

  String _getTimeText(Duration dur) {
    Duration duration = dur.abs();
    if (duration.compareTo(const Duration(hours: 1)) < 0) {
      if (duration.inMinutes == 1) {
        return "1 minute";
      } else {
        return '${duration.inMinutes} minutes';
      }
    } else {
      if (duration.inHours == 1) {
        return "1 hour";
      } else {
        return '${duration.inHours} hours';
      }
    }
  }

  Widget _getLocationActivationWidget(double verticalPadding) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: verticalPadding),
      child: Hero(
        tag: 'location',
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin, end: end);
        },
        child: _locationEnabled ? LocationInfo(
            bgColor: Colors.green,
            iconBgColor: Colors.green,
            icon: const Icon(Icons.check, color: Colors.lightGreen, size: 80),
            title: 'Activated',
            subtitle: 'You will receive notifications whenever you\'re near a task. Click "Disable" to disable location tracking (you can always activate it again later).',
            confirmText: 'Disable',
            onCancel: () {
              Navigator.of(context).pop();
            },
            onConfirm: () async {
              LocationCallbackHandler.onStop();
              widget.onLocationSetting(false);
              Navigator.pop(context);
              setState(() {});
            }
        ) : LocationInfo(
          bgColor: Colors.blue,
          iconBgColor: Colors.green,
          icon: const Icon(FontAwesomeIcons.earthAmericas, size: 80, color: Colors.blue),
          title: 'Get reminders!',
          subtitle: 'You can provide locations of a task to get a reminder when you arrive there. After pressing activate, make sure to accept the requested permissions!',
          confirmText: 'Activate',
          onCancel: () {
            Navigator.of(context).pop();
          },
          onConfirm: () async {
            if (await LocationCallbackHandler.onStart()) {
              widget.onLocationSetting(true);
            }
            Navigator.pop(context);
            setState(() {});
          },
        )
      ),
    );
  }

  Color _getBgColor(int val, int max) {
    ColorTween good = ColorTween(
        begin: Colors.lightBlueAccent, end: Colors.green);
    ColorTween mid = ColorTween(begin: Colors.yellow, end: Colors.orange);
    ColorTween bad = ColorTween(begin: Colors.orange, end: Colors.red);
    if (val <= max / 4) {
      return good.lerp(val / (max / 4)) ?? Colors.green;
    } else if (val <= 3 * max / 5) {
      val -= max ~/ 4;
      return mid.lerp(val / (max / 2)) ?? Colors.orange;
    } else {
      val -= max ~/ 2;
      return bad.lerp(val / (max / 4)) ?? Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FamilyTaskData>(
        stream: ds.taskDataForFamily,
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
                String name = snapshot.data == null ? '' : snapshot.data!
                    .name;
                int taskCount = snapshot.data == null ? 0 : snapshot.data!
                    .tasks.length;

                List<TaskData> archive = snapshot.data == null ? [] : snapshot
                    .data!.archive;
                List<TaskData> taskData = snapshot.data == null
                    ? []
                    : snapshot.data!.tasks;
                int archiveCount = archive.length;

                TaskData? lastTask = archiveCount > 0 ? archive[archiveCount -
                    1] : null;
                DateTime? lastArchived = archiveCount > 0
                    ? lastTask!.archived
                    : null;
                Duration? sinceLastArchived = archiveCount > 0 ? DateTime
                    .now().difference(lastArchived!) : null;
                Duration? archiveGap = archiveCount > 0 ? lastArchived!
                    .difference(lastTask!.due) : null;
                Color bgColor = _getBgColor(taskCount, maxTasks);
                TaskData? dueEarliest = taskData.isNotEmpty ? taskData
                    .reduce((cur, next) =>
                cur.due.isBefore(next.due)
                    ? cur
                    : next) : null;
                Duration? taskGap = taskData.isNotEmpty ? DateTime.now()
                    .difference(dueEarliest!.due) : null;

                return ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8, right: 10, left: 10),
                        child: InkWell(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (cont) {
                                  return Form(
                                    key: _formKey,
                                    child: AlertDialog(
                                        title: const Text('Edit Name',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        contentPadding: const EdgeInsets.only(
                                            top: 20, left: 24, right: 24),
                                        content: TextFormField(
                                          initialValue: name,
                                          maxLength: 20,
                                          decoration: const InputDecoration(
                                              hintText: 'Group Name',
                                              border: OutlineInputBorder(),
                                              counterText: ''
                                          ),
                                          onChanged: (String? value) {
                                            _input = value ?? '';
                                          },
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter a name';
                                            }
                                            return null;
                                          },
                                        ),
                                        actions: [
                                          TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }
                                          ),
                                          TextButton(
                                              child: const Text('Update'),
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  Navigator.pop(context);
                                                  await ds.updateFamilyName(
                                                      _input);
                                                }
                                              }
                                          ),
                                        ]
                                    ),
                                  );
                                }
                            );
                          },
                          child: Container(
                              alignment: Alignment.center,
                              child: Material(
                                  elevation: 5,
                                  color: Colors.transparent,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          stops: const [0.15, 0.9],
                                          colors: [
                                            bgColor.withOpacity(0.6),
                                            bgColor
                                          ],
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(27),
                                          topLeft: Radius.circular(27),
                                        )
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Container(
                                              padding: const EdgeInsets.only(top: 10, right: 10),
                                              child: AutoSizeText(name,
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      fontSize: 40, fontWeight: FontWeight.bold),
                                                  maxLines: 1)
                                          ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.only(
                                                bottom: 5),
                                            child: const Icon(
                                                Icons.edit, size: 30))
                                      ],
                                    ),
                                  )
                              )
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Material(
                          color: bgColor,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8.0),
                              child: _showID ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(widget.famID, style: const TextStyle(fontSize: 20), maxLines: 1),
                                  Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: widget.famID));
                                        },
                                      )
                                  )
                                ],
                              ) : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _showID = true;
                                    });
                                  },
                                  child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.only(right: 5),
                                          child: Icon(Icons.perm_identity_sharp),
                                        ),
                                        Text('Show ID', style: TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold)),
                                      ]
                                  ),
                                ),
                              )
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10, right: 10),
                        child: Material(
                          color: bgColor,
                          child: Container(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Card(
                                      elevation: 5,
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .end,
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top: 10, bottom: 10),
                                                    child: const Icon(
                                                        FontAwesomeIcons
                                                            .clipboard,
                                                        size: 110)
                                                ),
                                                Card(
                                                  margin: const EdgeInsets
                                                      .only(top: 10),
                                                  color: taskCount > 0
                                                      ? Colors.red
                                                      : Colors.green,
                                                  elevation: 5,
                                                  shape: const CircleBorder(),
                                                  child: taskCount > 0
                                                      ? Padding(
                                                    padding: const EdgeInsets
                                                        .all(16.0),
                                                    child: Text('$taskCount',
                                                        style: const TextStyle(
                                                            fontSize: 30,
                                                            fontWeight: FontWeight
                                                                .w900,
                                                            color: Colors
                                                                .white)),
                                                  )
                                                      :
                                                  const Icon(Icons.check,
                                                      color: Colors.white,
                                                      size: 45),
                                                )
                                              ],
                                            ),
                                            Container(
                                                padding: const EdgeInsets
                                                    .only(left: 25,
                                                    right: 25,
                                                    bottom: 20),
                                                child: const Text('To Do',
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: Colors
                                                            .lightBlue))
                                            ),
                                          ]
                                      )
                                  ),
                                  Card(
                                      elevation: 5,
                                      child: Column(
                                          mainAxisAlignment: MainAxisAlignment
                                              .end,
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        top: 14, bottom: 4),
                                                    child: const Icon(
                                                        FontAwesomeIcons
                                                            .boxArchive,
                                                        size: 110)
                                                ),
                                                Card(
                                                    margin: const EdgeInsets
                                                        .only(top: 3),
                                                    shape: const CircleBorder(),
                                                    color: Colors.green,
                                                    elevation: 5,
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .all(16.0),
                                                      child: Text(
                                                          '$archiveCount',
                                                          style: const TextStyle(
                                                              fontSize: 30,
                                                              fontWeight: FontWeight
                                                                  .w900,
                                                              color: Colors
                                                                  .white)),
                                                    )
                                                )
                                              ],
                                            ),
                                            Container(
                                                padding: const EdgeInsets
                                                    .only(left: 10,
                                                    right: 10,
                                                    bottom: 20),
                                                child: const Text('Archived',
                                                    style: TextStyle(
                                                        fontSize: 30,
                                                        color: Colors
                                                            .lightBlue))
                                            ),
                                          ]
                                      )
                                  )
                                ]
                            ),
                          ),
                        ),
                      ),
                      dueEarliest != null ? DataCard(
                        taskColor: dueEarliest.color,
                        taskName: dueEarliest.name,
                        textSpan: TextSpan(
                            style: const TextStyle(
                                color: Colors.black, fontSize: 20),
                            children: [
                              TextSpan(text: taskGap!.isNegative
                                  ? 'Due in '
                                  : 'Was due ', style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: taskGap.isNegative ? Colors
                                      .lightGreenAccent : Colors.amber)),
                              TextSpan(text: _getTimeText(taskGap),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              TextSpan(
                                  text: taskGap.isNegative ? '.' : ' ago.'),
                            ]
                        ),
                      ) : const AccountCard(
                        icon: FontAwesomeIcons.listCheck,
                        opacity: 0.7,
                        title: 'Task List Empty',
                        subtitle: 'You\'re free!',
                        iconSize: 200,
                        bottomPadding: 10,
                        bgColor: Colors.lightGreen,
                        iconColor: Colors.green,
                      ),
                      lastArchived != null ? Stack(
                        alignment: Alignment.topRight,
                        children: [
                          DataCard(
                            taskName: lastTask!.name,
                            taskColor: lastTask.color,
                            textSpan: TextSpan(
                                text: 'Completed ',
                                style: const TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(text: _getTimeText(archiveGap!),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  TextSpan(text: archiveGap.isNegative
                                      ? ' before '
                                      : ' after ',
                                      style: TextStyle(
                                          color: archiveGap.isNegative
                                              ? Colors.lightGreenAccent
                                              : Colors.amber,
                                          fontWeight: FontWeight.bold)),
                                  const TextSpan(text: 'the deadline.')
                                ]
                            ),
                          ),
                          Material(
                              shape: const CircleBorder(),
                              color: _getBgColor(
                                  sinceLastArchived!.inHours, 72),
                              elevation: 10,
                              child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment
                                        .spaceBetween,
                                    children: [
                                      Text(_getTimeText(sinceLastArchived)
                                          .split(' ')[0],
                                          style: const TextStyle(fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text('${_getTimeText(sinceLastArchived)
                                          .split(' ')[1]} ago',
                                          style: const TextStyle(fontSize: 8))
                                    ],
                                  )
                              )
                          )
                        ],
                      ) : const AccountCard(
                        opacity: 0.7,
                        icon: FontAwesomeIcons.boxOpen,
                        title: 'Archive Empty',
                        subtitle: 'Complete some tasks!',
                        iconSize: 175,
                        bottomPadding: 40,
                        bgColor: Colors.red,
                        iconColor: Colors.orangeAccent,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                              HeroDialogRoute(builder: (context) {
                                return _getLocationActivationWidget(MediaQuery
                                    .of(context)
                                    .size
                                    .height / 2 - 150);
                              }));
                        },
                        child: Hero(
                          tag: 'location',
                          child: AccountCard(
                            bgColor: _locationEnabled ? Colors.green : Colors
                                .blue,
                            iconColor: _locationEnabled
                                ? Colors.lightGreen
                                : Colors.lightBlueAccent,
                            icon: _locationEnabled
                                ? Icons.check
                                : FontAwesomeIcons.mapLocationDot,
                            title: 'Location',
                            subtitle: _locationEnabled
                                ? 'Activated'
                                : 'Click for Information',
                            iconSize: _locationEnabled ? 300 : 250,
                            bottomPadding: _locationEnabled ? 85 : 45,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Container(
                                padding: const EdgeInsets.only(right: 10),
                                child: GroupIDWidget(famID: widget.famID)
                            ),
                            LeaveWidget(onLeave: () {
                              widget.onLeave();
                              setState(() {});
                            })
                          ],
                        ),
                      )
                    ]
                );
              case ConnectionState.done:
                return const Center(
                    child: Text(
                        'Connection Closed', style: TextStyle(fontSize: 30))
                );
            }
          }
        }
    );
  }
}