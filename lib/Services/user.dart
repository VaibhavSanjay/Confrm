import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_data.dart';

class UserService {
  String famID;
  UserService(this.famID);

  final CollectionReference taskDataCollection = FirebaseFirestore.instance.collection('family_tasks');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future newUser(String authID) async {
    await userCollection.doc(authID).set({
      'group': '0',
      'location': false
    });
  }

  Future<UserData> getUserFam(String id) async {
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