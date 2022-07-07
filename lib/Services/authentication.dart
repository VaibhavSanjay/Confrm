import 'package:family_tasks/Services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum SignResults {
  weakPass,
  emailInUse,
  noUser,
  wrongPass,
  invalidEmail,
  success,
  fail
}

class AuthenticationService {
  static final AuthenticationService _instance = AuthenticationService._();

  AuthenticationService._();

  factory AuthenticationService() {
    return _instance;
  }

  Future<SignResults> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return SignResults.noUser;
      } else if (e.code == 'wrong-password') {
        return SignResults.wrongPass;
      } else if (e.code == 'invalid-email') {
        return SignResults.invalidEmail;
      } else {
        return SignResults.fail;
      }
    }
    return SignResults.success;
  }

  Future signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<SignResults> signUp(String name, String email, String password) async {
    final UserCredential userCredential;
    try {
      userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return SignResults.weakPass;
      } else if (e.code == 'email-already-in-use') {
        return SignResults.emailInUse;
      } else if (e.code == 'invalid-email') {
        return SignResults.invalidEmail;
      } else {
        return SignResults.fail;
      }
    }
    await userCredential.user?.updateDisplayName(name);
    await DatabaseService('').newUser(userCredential.user!.uid);
    return SignResults.success;
  }

  String? get email {
    return FirebaseAuth.instance.currentUser?.providerData[0].email;
  }

  String? get name {
    return FirebaseAuth.instance.currentUser?.providerData[0].displayName;
  }

  String? get id {
    return FirebaseAuth.instance.currentUser?.uid;
  }
}