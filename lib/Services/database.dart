import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/user_data.dart';
import '../pages/Helpers/constants.dart';

class DatabaseService {
  String famID;
  DatabaseService(this.famID);

  final CollectionReference taskDataCollection = FirebaseFirestore.instance.collection('family_tasks');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

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
            status: Status.values[data['data'][index]['status']],
            due: (data['data'][index]['due'] as Timestamp).toDate(),
            color: availableColors[data['data'][index]['color']],
            location: data['data'][index]['location'],
            coords: data['data'][index]['coords'].cast<double>(),
            lastRem: (data['data'][index]['lastRem'] as Timestamp).toDate()
          )
        ),
        archive: List<TaskData>.generate(
            data['archive'].length,
            (int index) => TaskData(
              name: data['archive'][index]['name'],
              desc: data['archive'][index]['desc'],
              taskType: TaskType.values[data['archive'][index]['taskType']],
              status: Status.values[data['archive'][index]['status']],
              due: (data['archive'][index]['due'] as Timestamp).toDate(),
              color: availableColors[data['archive'][index]['color']],
              location: data['archive'][index]['location'],
              coords: data['archive'][index]['coords'].cast<double>(),
              lastRem: (data['archive'][index]['lastRem'] as Timestamp).toDate(),
              archived: (data['archive'][index]['archived'] as Timestamp).toDate()
            )
        ),
        users: (Map<String, dynamic>.from(data['users'])).map(
          (key, value) => MapEntry(
            key,
            UserData(
              name: value['name'] as String
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
        'status': Status.values.indexOf(td.status),
        'due': Timestamp.fromDate(td.due),
        'color': availableColors.indexOf(td.color),
        'location': td.location,
        'coords': td.coords.cast<dynamic>(),
        'lastRem': Timestamp.fromDate(td.lastRem)
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
        'status': Status.values.indexOf(td.status),
        'due': Timestamp.fromDate(td.due),
        'color': availableColors.indexOf(td.color),
        'location': td.location,
        'coords': td.coords.cast<dynamic>(),
        'lastRem': Timestamp.fromDate(td.lastRem),
        'archived': Timestamp.fromDate(td.archived)
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
      'archive': []
    })).id;
  }

  Future newUser(String authID) async {
    await userCollection.doc(authID).set({
      'group': '0',
      'location': false
    });
  }

  Future<UserData> getUser(String id) async {
    return UserData(famID: (await userCollection.doc(id).get()).get('group'), location: (await userCollection.doc(id).get()).get('location'));
  }

  Future<bool> famExists(String authID, String famID) async {
    await userCollection.doc(authID).update({'group': famID});
    return (await taskDataCollection.doc(famID).get()).exists;
  }

  Future setUserFamily(String authID, String famID) async {
    this.famID = famID;
    await userCollection.doc(authID).update({'group': famID});
  }

  Future updateUserLocation(String authID, bool location) async {
    await userCollection.doc(authID).update({'location': location});
  }

  Future leaveUserFamily(String authID) async {
    famID = '0';
    await userCollection.doc(authID).update({'group': '0'});
  }
}