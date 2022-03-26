import 'package:family_tasks/pages/Helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../Services/database.dart';
import '../models/family_task_data.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key, required this.onJoinOrCreate}) : super(key: key);

  final Function(String famID) onJoinOrCreate;


  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  static late String? famID;
  static bool setID = false;
  static late DatabaseService ds;
  static late Stream<FamilyTaskData> stream;
  String _input = '';
  final _formKey = GlobalKey<FormState>();
  bool _foundFamily = false;

  static void setFamID(String? ID) {
    famID = ID;
    setID = true;
    ds = DatabaseService(famID);
    if (famID != null) {
      stream = ds.taskDataForFamily;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _getButton(IconData icon, String text, Function() onPressed) {
      return Container(
        margin: const EdgeInsets.only(right: 20, left: 10),
        child: TextButton(
            onPressed: onPressed,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 20),
                      child: Icon(icon, size: 40)
                  ),
                  Text(text, style: const TextStyle(fontSize: 40))
                ]
            )
        ),
      );
    }

    if (setID) {
      return famID == null ? Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Card(
                elevation: 5,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: const Text('Organize your Family!', style: TextStyle(fontSize: 30))
                )
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: Card(
                elevation: 5,
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _getButton(
                        FontAwesomeIcons.personCirclePlus,
                        'Create',
                        () {
                          _input = '';
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Form(
                                key: _formKey,
                                child: AlertDialog(
                                  title: const Text('Create New Family', style: TextStyle(fontWeight: FontWeight.bold)),
                                  contentPadding: const EdgeInsets.only(top: 20, left: 24, right: 24),
                                  content: TextFormField(
                                    maxLength: 20,
                                    decoration: const InputDecoration(
                                        hintText: 'Family Name',
                                        border: OutlineInputBorder(),
                                        counterText: ''
                                    ),
                                    onChanged: (String? value) {
                                      _input = value ?? '';
                                    },
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a family name';
                                      }
                                      return null;
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: (){
                                          Navigator.pop(context);
                                        }
                                    ),
                                    TextButton(
                                      child: const Text('Create'),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          Navigator.pop(context);
                                          famID = await ds.addNewFamily(_input);
                                          widget.onJoinOrCreate(famID!);
                                        }
                                      }
                                    ),
                                  ]
                                ),
                              );
                            }
                          );
                        }
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: const Text('Or', style: TextStyle(fontSize: 30))
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: _getButton(
                        Icons.people,
                        'Join',
                         () {
                            _input = '';
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Form(
                                  key: _formKey,
                                  child: AlertDialog(
                                      title: const Text('Join Family', style: TextStyle(fontWeight: FontWeight.bold)),
                                      contentPadding: const EdgeInsets.only(top: 20, right: 24, left: 24),
                                      content: TextFormField(
                                        maxLength: 30,
                                        decoration: const InputDecoration(
                                            hintText: 'Family ID',
                                            border: OutlineInputBorder(),
                                            counterText: ''
                                        ),
                                        onChanged: (String? value) {
                                          _input = value ?? '';
                                        },
                                        validator: (String? value) {
                                          return _foundFamily ? null : 'Invalid ID';
                                        },
                                      ),
                                      actions: [
                                        TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: (){
                                              Navigator.pop(context);
                                            }
                                        ),
                                        TextButton(
                                            child: const Text('Join'),
                                            onPressed: () async {
                                              _foundFamily = await ds.famExists(_input.isEmpty ? '0' : _input);
                                              if (_formKey.currentState!.validate()) {
                                                Navigator.pop(context);
                                                famID = _input;
                                                widget.onJoinOrCreate(famID!);
                                              }
                                            }
                                        ),
                                      ]
                                  ),
                                );
                              }
                            );
                         }
                      )
                    )
                  ],
                ),
              ),
            )
          ]
      ) : StreamBuilder<FamilyTaskData>(
        stream: stream,
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
                String name = snapshot.data == null ? '' : snapshot.data!.name;
                int taskCount = snapshot.data == null ? 0 : snapshot.data!.tasks.length;

                List<TaskData> archive = snapshot.data == null ? [] : snapshot.data!.archive;
                int archiveCount = archive.length;
                DateTime? lastArchived = archiveCount > 0 ? archive[archiveCount - 1].archived.toLocal() : null;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Card(
                        elevation: 5,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Text(name, style: const TextStyle(fontSize: 50))
                        )
                      )
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Card(
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 30),
                              child: Text('Tasks Remaining: $taskCount', style: const TextStyle(fontSize: 30))
                            ),
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text('Tasks Archived: $archiveCount', style: const TextStyle(fontSize: 30))
                            ),
                            lastArchived != null ?
                            Container(
                              padding: const EdgeInsets.only(left: 10, bottom: 10),
                              child: Text('Last Archived Task: ${archive[0].name}, '
                                  '${daysOfWeek[lastArchived.weekday]} '
                                  '${DateFormat('h:mm a').format(lastArchived)}',
                                style: const TextStyle(fontSize: 20, color: Colors.grey)
                              ),
                            ) : const SizedBox.shrink()
                          ]
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        style: TextButton.styleFrom(elevation: 5,
                            backgroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 18)
                        ),
                        child: const Text('View Family ID'),
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (cont) {
                              return FamilyIDWidget(famID: famID!);
                            }
                          );
                        },
                      ),
                    )
                  ]
                );
              case ConnectionState.done:
                return const Center(
                    child: Text('Connection Closed', style: TextStyle(fontSize: 30))
                );
            }
          }
        }
      );
    } else {
      return const Center(
          child: SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(),
          )
      );
    }

  }
}

class FamilyIDWidget extends StatefulWidget {
  final String famID;

  const FamilyIDWidget({Key? key, required this.famID}) : super(key: key);

  @override
  State<FamilyIDWidget> createState() => _FamilyIDWidgetState();
}

class _FamilyIDWidgetState extends State<FamilyIDWidget> {
  IconData _curIcon = Icons.copy;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Family ID', style: TextStyle(fontWeight: FontWeight.bold))),
      contentPadding: const EdgeInsets.only(top: 20, left: 12, bottom: 24, right: 0),
      content: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                child: Text(widget.famID, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30))
            ),
          ),
          IconButton(
              icon: Icon(_curIcon, size: 30),
              onPressed: (){
                setState(() {
                  _curIcon = FontAwesomeIcons.clipboardCheck;
                  Clipboard.setData(ClipboardData(text: widget.famID));
                });
              }
          )
        ],
      ),
    );
  }
}
