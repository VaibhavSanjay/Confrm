import 'package:family_tasks/Services/authentication.dart';
import 'package:family_tasks/Services/location_callback.dart';
import 'package:family_tasks/pages/Helpers/account_option_widgets.dart';
import 'package:family_tasks/pages/Helpers/constants.dart';
import 'package:family_tasks/pages/Helpers/user_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Services/authentication.dart';
import '../Services/database.dart';
import '../models/family_task_data.dart';
import '../models/user_data.dart';
import 'Helpers/account_card.dart';
import 'Helpers/hero_dialogue_route.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required this.famID, required this.onLeave, required this.location}) : super(key: key);

  final String famID;
  final bool location;
  final Function() onLeave;

  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  bool _locationEnabled = false;
  late DatabaseService ds = DatabaseService(widget.famID);
  AuthenticationService auth = AuthenticationService();
  final _formKey = GlobalKey<FormState>();


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

  Widget _topMenuButton(IconData iconData, String text, Color noteColor, String noteText) {
    return Container(
        decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.cyan
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(iconData, size: 35),
                    const Divider(height: 5, color: Colors.transparent),
                    Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold))
                  ],
                ),
            ),
            Positioned(
              right: 0,
              left: 45,
              top: 0,
              child: Card(
                  color: noteColor,
                  shape: const CircleBorder(),
                  child: Align(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Text(noteText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    alignment: Alignment.center,)
              ),
            )
          ],
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FamilyTaskData>(
        stream: ds.taskDataForFamily,
        builder: (context, AsyncSnapshot<FamilyTaskData> snapshot) {
          if (snapshot.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to load content'),));
            return const Center(
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(),
                )
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
                Map<String, UserData> users = (snapshot.data == null ? [] :
                    snapshot.data!.users) as Map<String, UserData>;
                int archiveCount = archive.length;

                Map<String, int> tasksCompleted = users.map((key, value) => MapEntry(key, 0));
                for (var td in archive) {
                  tasksCompleted[td.completedBy] == null ? null :
                    tasksCompleted[td.completedBy] = tasksCompleted[td.completedBy]! + 1;
                }
                int curUser = tasksCompleted.keys.toList().indexOf(auth.id!);

                Map<int, int> dayTasks = {1: 0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0};
                Map<int, int> userDayTasks = {1: 0, 2:0, 3:0, 4:0, 5:0, 6:0, 7:0};
                DateTime today = DateTime.now();
                for (var td in archive) {
                  if (today.difference(td.archived).inDays < 7) {
                    dayTasks[td.archived.weekday] = dayTasks[td.archived.weekday]! + 1;
                    if (td.completedBy == auth.id!) {
                      userDayTasks[td.archived.weekday] = userDayTasks[td.archived.weekday]! + 1;
                    }
                  }
                }

                taskData.sort((a, b) => a.due.compareTo(b.due));
                List<TaskData> lateTasks = taskData.where((td) => DateTime.now().isAfter(td.due)).toList();
                bool late = lateTasks.isNotEmpty;
                if (!late) {
                  lateTasks = taskData.take(3).toList();
                }

                Color bgColor = _getBgColor(taskCount, maxTasks);

                return Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, top: 8),
                  child: ListView(
                      children: [
                        Card(
                          elevation: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 150,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 105,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 50,
                                      child: Form(
                                        key: _formKey,
                                        child: TextFormField(
                                          cursorColor: Colors.cyanAccent,
                                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,
                                              overflow: TextOverflow.ellipsis),
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
                                          ),
                                          initialValue: name,
                                          maxLength: 30,
                                          onChanged: (String? value) async {
                                            if (_formKey.currentState!.validate() && value != null) {
                                              await ds.updateFamilyName(
                                                  value);
                                            }
                                          },
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              print('here');
                                              return 'Please enter a name';
                                            }
                                            return null;
                                          }
                                        ),
                                      )
                                    ),
                                    Positioned(
                                      top: 5,
                                      right: 5,
                                      child: Hero(
                                        tag: 'group_id',
                                        child: CircleAvatar(
                                          backgroundColor: Colors.cyanAccent,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: IconButton(
                                              color: Colors.black,
                                              icon: const Icon(Icons.people),
                                              onPressed: () {
                                                Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                                                  return FamilyIDPopUp(famID: widget.famID);
                                                }));
                                              },
                                            ),
                                          ),
                                        ),
                                      )
                                    ),
                                    Positioned(
                                      top: 70,
                                      left: 0,
                                      right: 100,
                                      child: _topMenuButton(FontAwesomeIcons.clipboardList, 'Tasks', Colors.red, '$taskCount')
                                    ),
                                    Positioned(
                                        top: 70,
                                        right: 0,
                                        left: 100,
                                        child: _topMenuButton(FontAwesomeIcons.boxArchive, 'Archive', Colors.green, '$archiveCount')
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                    spacing: 10,
                                    children: users.map(
                                            (key, value) => MapEntry(
                                            key,
                                            SizedBox(
                                                width: 60,
                                                child: UserDataHelper.avatarColumnFromUserData(value, 30, Colors.black)
                                            )
                                        )
                                    ).values.toList()
                                ),
                              ),
                            ],
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                          )
                        ),
                        const Divider(height: 15, color: Colors.transparent),
                        late ? LateStatusCard(tasks: lateTasks) : CaughtUpStatusCard(tasks: lateTasks),
                        const Divider(height: 15, color: Colors.transparent),
                        SizedBox(
                          height: 340,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 42,
                                child: DaysCard(
                                  dayTasks: dayTasks.values.toList(),
                                  userDayTasks: userDayTasks.values.toList(),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 42,
                                child: ContributeCard(
                                  users: tasksCompleted.keys.map((s) => users[s]!).toList(),
                                  tasksCompleted: tasksCompleted.values.toList(),
                                  curUser: curUser,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 10, color: Colors.transparent),
                        AccountCard(
                          locationEnabled: _locationEnabled,
                          onActivate: () async {
                            Navigator.pop(context);
                            if (await LocationCallbackHandler.onStart()) {
                              ds.updateUserLocation(true);
                              _locationEnabled = true;
                            } else {
                              print('Error starting locator (notifications problem?)');
                            }
                          },
                          onDisable: () async {
                            Navigator.pop(context);
                            LocationCallbackHandler.onStop();
                            ds.updateUserLocation(false);
                            _locationEnabled = false;
                          },
                          getLocation: () async {
                            return (await ds.getUser()).location;
                          },
                        ),
                      ]
                  ),
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