import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String name;
  final String email;
  String? displayPicUrl;
  String? groupId;

  User({
    required this.uid,
    required this.name,
    required this.email,
    this.displayPicUrl,
    this.groupId,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'name': name,
        'email': email,
        'displayPicUrl': displayPicUrl,
        'groupId': groupId,
      };

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data()! as Map<String, dynamic>;
    return User(
        uid: data['uid'],
        name: data['name'],
        email: data['email'],
        displayPicUrl: data['displayPicUrl'],
        groupId: data['groupId']);
  }
}
