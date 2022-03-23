import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseService {
  final String famID;
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
            name: data['data'][index]['name']
          )
        ),
        name: data['name']
    );
  }
}