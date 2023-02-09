import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_chat/models/group.dart';
import 'package:group_chat/models/user.dart' as model;
import 'package:uuid/uuid.dart';

class FireStoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Stream<model.User> get user {
    return _firestore
        .collection('users')
        .doc(_firebaseAuth.currentUser!.uid)
        .snapshots()
        .map((DocumentSnapshot snapshot) => model.User.fromFirestore(snapshot));
  }

  Future<String> createGroup(String name) async {
    String status = 'error';
    List<String> members = [];
    List<String> messages = [];
    String groupId = const Uuid().v4();
    members.add(_firebaseAuth.currentUser!.uid);

    Group group = Group(
        groupId: groupId,
        name: name,
        members: members,
        groupAdminId: _firebaseAuth.currentUser!.uid,
        messages: messages);

    try {
      await _firestore.collection('groups').doc(groupId).set(group.toJson());
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({'groupId': groupId});
      status = 'success';
    } catch (e) {
      status = e.toString();
    }
    return status;
  }

  Future<String> joinGroup(String groupId) async {
    String status = 'error';
    List<String> members = [];
    members.add(_firebaseAuth.currentUser!.uid);
    try {
      await _firestore
          .collection('groups')
          .doc(groupId)
          .update({'members': FieldValue.arrayUnion(members)});
      await _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser!.uid)
          .update({'groupId': groupId});
      status = 'success';
    } catch (e) {
      status = e.toString();
    }
    return status;
  }

  Future<String> leaveGroup(model.User user) async {
    var status = 'error';

    try {
      await _firestore.collection('groups').doc(user.groupId).update({
        'members': FieldValue.arrayRemove([user.uid])
      });
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'groupId': null});
      status = 'success';
    } catch (e) {
      status = e.toString();
    }
    return status;
  }
}
