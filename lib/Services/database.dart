import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:firebase_core/firebase_core.dart';
import '../pages/Helpers/constants.dart';

class DatabaseService {
  final String? famID;
  DatabaseService(this.famID);

  final CollectionReference taskDataCollection = FirebaseFirestore.instance.collection('family_tasks');

  static Future<void> initializeFirebase() async {
    await Firebase.initializeApp();
  }

  Stream<FamilyTaskData> get taskDataForFamily {
    return taskDataCollection.doc(famID).snapshots().map(_taskDataFromSnapshot);
  }

  FamilyTaskData _taskDataFromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FamilyTaskData(
        tasks: List<TaskData>.generate(
          data['data'].length,
          (int index) => TaskData(
            name: data['data'][index]['name'],
            desc: data['data'][index]['desc'],
            taskType: TaskType.values[data['data'][index]['taskType']],
            status: Status.values[data['data'][index]['status']],
            due: (data['data'][index]['due'] as Timestamp).toDate(),
            color: availableColors[data['data'][index]['color']],
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
              archived: (data['archive'][index]['archived'] as Timestamp).toDate()
            )
        ),
        name: data['name']
    );
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
        'archived': Timestamp.fromDate(td.archived)
      }).toList()
    });
  }

  Future<String> addNewFamily(String name) async {
    return (await taskDataCollection.add({
      'name': name,
      'data': [],
      'archive': []
    })).id;
  }

  Future<bool> famExists(String name) async {
    return (await taskDataCollection.doc(name).get()).exists;
  }

}