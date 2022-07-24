import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tasks/Services/authentication.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_data.dart';
import '../pages/Helpers/constants.dart';
import '../pages/Helpers/user_data_helper.dart';

class DatabaseService {
  String famID;
  DatabaseService(this.famID);

  final CollectionReference taskDataCollection = FirebaseFirestore.instance.collection('family_tasks');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final AuthenticationService auth = AuthenticationService();

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Stream<FamilyTaskData> get taskDataForFamily {
    return taskDataCollection.doc(famID).snapshots().map(_taskDataFromSnapshot);
  }

  Future<FamilyTaskData> getSingleSnapshot() async {
    return _taskDataFromSnapshot(await taskDataCollection.doc(famID).get());
  }

  FamilyTaskData _taskDataFromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    FamilyTaskData ret = FamilyTaskData(
        tasks: List<TaskData>.generate(
          data['data'].length,
          (int index) => TaskData(
            name: data['data'][index]['name'],
            desc: data['data'][index]['desc'],
            taskType: TaskType.values[data['data'][index]['taskType']],
            due: (data['data'][index]['due'] as Timestamp).toDate(),
            color: availableColors[data['data'][index]['color']],
            location: data['data'][index]['location'],
            coords: data['data'][index]['coords'].cast<double>(),
            lastRem: (data['data'][index]['lastRem'] as Timestamp).toDate(),
            reminded: data['data'][index]['reminded'].cast<String>(),
            assignedUsers: data['data'][index]['assignedUsers'].cast<String>()
          )
        ),
        archive: List<TaskData>.generate(
            data['archive'].length,
            (int index) => TaskData(
              name: data['archive'][index]['name'],
              desc: data['archive'][index]['desc'],
              taskType: TaskType.values[data['archive'][index]['taskType']],
              due: (data['archive'][index]['due'] as Timestamp).toDate(),
              color: availableColors[data['archive'][index]['color']],
              location: data['archive'][index]['location'],
              coords: data['archive'][index]['coords'].cast<double>(),
              lastRem: (data['archive'][index]['lastRem'] as Timestamp).toDate(),
              reminded: data['archive'][index]['reminded'].cast<String>(),
              assignedUsers: data['archive'][index]['assignedUsers'].cast<String>(),
              archived: (data['archive'][index]['archived'] as Timestamp).toDate(),
              completedBy: data['archive'][index]['completedBy']
            )
        ),
        users: (Map<String, dynamic>.from(data['users'])).map(
          (key, value) => MapEntry(
            key,
            UserData(
              name: value['name'] as String,
              email: value['email'] as String,
              color: Color(value['color'] as int)
            )
          )
        ),
        name: data['name']
    );
    return ret;
  }

  Future<void> updateTaskData(List<TaskData> taskData) async {
    await taskDataCollection.doc(famID).update({
      'data': taskData.map((td) => {
        'name': td.name,
        'desc': td.desc,
        'taskType': TaskType.values.indexOf(td.taskType),
        'due': Timestamp.fromDate(td.due),
        'color': availableColors.indexOf(td.color),
        'location': td.location,
        'coords': td.coords.cast<dynamic>(),
        'lastRem': Timestamp.fromDate(td.lastRem),
        'reminded': td.reminded.cast<dynamic>(),
        'assignedUsers': td.assignedUsers.cast<dynamic>()
      }).toList()
    });
  }

  Future<void> updateArchiveData(List<TaskData> taskData) async {
    await taskDataCollection.doc(famID).update({
      'archive': taskData.map((td) =>
      {
        'name': td.name,
        'desc': td.desc,
        'taskType': TaskType.values.indexOf(td.taskType),
        'due': Timestamp.fromDate(td.due),
        'color': availableColors.indexOf(td.color),
        'location': td.location,
        'coords': td.coords.cast<dynamic>(),
        'lastRem': Timestamp.fromDate(td.lastRem),
        'reminded': td.reminded.cast<dynamic>(),
        'assignedUsers': td.assignedUsers.cast<dynamic>(),
        'archived': Timestamp.fromDate(td.archived),
        'completedBy': td.completedBy
      }).toList()
    });
  }

  Future<void> updateFamilyName(String name) async {
    await taskDataCollection.doc(famID).update({
      'name': name
    });
  }

  Future<String> addNewFamily(String name) async {
    return (await taskDataCollection.add({
      'name': name,
      'data': [],
      'archive': [],
      'users': {}
    })).id;
  }

  Future newUser(String authID) async {
    await userCollection.doc(authID).set({
      'group': '0',
      'location': false
    });
  }

  Future<UserData> getUser() async {
    return UserData(
      name: auth.name!,
      email: auth.email!,
      famID: (await userCollection.doc(auth.id!).get()).get('group'),
      location: (await userCollection.doc(auth.id!).get()).get('location'));
  }

  Future<bool> famExists(String famID) async {
    await userCollection.doc(auth.id!).update({'group': famID});
    return (await taskDataCollection.doc(famID).get()).exists;
  }

  Future setUserFamily(String famID) async {
    await userCollection.doc(auth.id!).update({'group': famID});

    this.famID = famID;
    Map<String, dynamic> current = (await taskDataCollection.doc(famID).get()).get('users');
    current[auth.id!] = {
      'name': auth.name!,
      'email': auth.email!,
      'color': UserDataHelper.getRandomColor().value
    };
    taskDataCollection.doc(famID).update({
      'users': current
    });
  }

  Future updateUserLocation(bool location) async {
    await userCollection.doc(auth.id!).update({'location': location});
  }

  Future leaveUserFamily() async {
    Map<String, dynamic> current = (await taskDataCollection.doc(famID).get()).get('users');
    current.remove(auth.id!);
    await taskDataCollection.doc(famID).update({
      'users': current
    });
    await userCollection.doc(auth.id!).update({'group': '0'});
  }
}