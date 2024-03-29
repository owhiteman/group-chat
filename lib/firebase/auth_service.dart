import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:group_chat/firebase/storage_methods.dart';
import 'package:group_chat/models/user.dart' as model;

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<String?> signIn(
      {required String email, required String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return 'Success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp(
      {required String email,
      required String password,
      required String name,
      Uint8List? file}) async {
    try {
      UserCredential userCred = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      String? photoUrl = file != null
          ? await StorageMethods().uploadImageToStorage('displayPics', file)
          : null;

      model.User user = model.User(
        uid: userCred.user!.uid,
        name: name,
        email: email,
        displayPicUrl: photoUrl,
        groupId: null,
      );

      await _firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .set(user.toJson());

      return 'Success';
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
