import 'package:family_tasks/pages/Helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../Services/database.dart';
import '../models/family_task_data.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".


  @override
  State<AccountPage> createState() => AccountPageState();
}

class AccountPageState extends State<AccountPage> {
  static late String? famID;
  static bool setID = false;
  static late DatabaseService ds;
  static late Stream<FamilyTaskData> stream;

  static void setFamID(String? ID) {
    famID = ID;
    setID = true;
    if (famID != null) {
      ds = DatabaseService(famID!);
      stream = ds.taskDataForFamily;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _getButton(IconData icon, String text) {
      return SizedBox(
        width: 205,
        child: TextButton(
            onPressed: (){},
            child: Row(
                children: [
                  Container(
                      padding: const EdgeInsets.only(right: 30),
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
            const Text('Organize your Family!', style: TextStyle(fontSize: 30)),
            Container(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    _getButton(Icons.add_circle, 'Create'),
                    _getButton(Icons.people, 'Join')
                  ],
                )
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
                DateTime hourAgo = DateTime.now().toUtc().subtract(const Duration(hours: 1));
                archive = archive.where((td) => td.archived.isAfter(hourAgo)).toList();
                ds.updateArchiveData(archive);

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
      content: Row(
        children: [
          Flexible(
            flex: 1,
            child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                child: Text('73WakrfVbNJBaAmhQtEeDv', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30))
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
