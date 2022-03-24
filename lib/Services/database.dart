import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final String famID;
  final List<Color> _availableColors = [Colors.red, Colors.orange, Colors.yellow, Colors.green,
    Colors.blue, Colors.indigo, Colors.purple, Colors.grey];
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
            color: _availableColors[data['data'][index]['color']],
            order: data['data'][index]['order'].toDouble()
          )
        ),
        name: data['name']
    );
  }
}