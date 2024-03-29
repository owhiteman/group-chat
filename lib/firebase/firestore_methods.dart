import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_chat/models/group.dart';
import 'package:group_chat/models/user.dart' as model;
import 'package:uuid/uuid.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

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
    String groupId = const Uuid().v4();
    members.add(_firebaseAuth.currentUser!.uid);

    Group group = Group(
        groupId: groupId,
        name: name,
        members: members,
        groupAdminId: _firebaseAuth.currentUser!.uid);

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

  void sendMessage(types.PartialText partialMessage, String groupId) async {
    types.Message message;

    message = types.TextMessage.fromPartial(
      author: types.User(id: _firebaseAuth.currentUser!.uid),
      id: const Uuid().v4(),
      partialText: partialMessage,
    );

    final messageMap = message.toJson();
    messageMap.removeWhere((key, value) => key == 'author' || key == 'id');
    messageMap['authorId'] = _firebaseAuth.currentUser!.uid;
    messageMap['createdAt'] = FieldValue.serverTimestamp();
    messageMap['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(messageMap);
  }

  Stream<List<types.Message>> messages(
      String groupId, List<types.User> groupUsers) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.fold<List<types.Message>>(
            [],
            (previousValue, doc) {
              final data = doc.data();
              final author = groupUsers.firstWhere(
                (u) => u.id == data['authorId'],
                orElse: () => types.User(id: data['authorId'] as String),
              );

              data['author'] = author.toJson();
              data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
              data['id'] = doc.id;
              data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;

              return [...previousValue, types.Message.fromJson(data)];
            },
          ),
        );
  }

  Stream<List<String>> groupUserIds(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((event) {
      final data = event.data();
      final groupIds = data!['members'] ?? [];
      return List<String>.from(groupIds);
    });
  }

  Stream<List<types.User>> groupAuthorDetails(List<String> groupIds) {
    return _firestore
        .collection('users')
        .where('uid', whereIn: groupIds)
        .snapshots()
        .map(
          (event) => event.docs.fold<List<types.User>>(
            [],
            (previousValue, element) {
              final data = element.data();
              final user = types.User(
                id: data['uid'] as String,
                firstName: data['name'] as String,
                imageUrl: data['displayPicUrl'] as String,
              );
              return [...previousValue, user];
            },
          ),
        );
  }

  Future<model.User> getUserDetails(String uid) async {
    var result = await _firestore.collection('users').doc(uid).get();
    var userData = result.data()!;

    var userDetails =
        model.User(uid: uid, name: userData['name'], email: userData['email']);

    if (userData['displayPicUrl'] != null) {
      userDetails.displayPicUrl = userData['displayPicUrl'];
    }

    return userDetails;
  }
}
