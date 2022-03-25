import 'package:family_tasks/pages/Helpers/constants.dart';
import 'package:flutter/material.dart';
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
                List<TaskData> archive = (snapshot.data == null ? [] : snapshot.data!.archive)
                  ..sort((a, b) => a.archived.isAfter(b.archived) ? 1 : -1);
                int archiveCount = archive.length;
                DateTime? lastArchived = archiveCount > 0 ? archive[0].archived.toLocal() : null;
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
                          child: Text(name, style: const TextStyle(fontSize: 30))
                        )
                      )
                    ),
                    Card(
                      elevation: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tasks Remaining: $taskCount', style: const TextStyle(fontSize: 20)),
                          Text('Tasks Archived: $archiveCount', style: const TextStyle(fontSize: 20)),
                          lastArchived != null ?
                          Text('Last Archived Task: ${archive[0].name}, '
                              '${daysOfWeek[lastArchived.weekday]} '
                              '${DateFormat('h:mm a').format(lastArchived)}'
                          ) : const SizedBox.shrink()
                        ]
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