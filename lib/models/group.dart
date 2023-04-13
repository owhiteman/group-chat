import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String groupId;
  final String name;
  final List members;
  final String groupAdminId;

  Group({
    required this.groupId,
    required this.name,
    required this.members,
    required this.groupAdminId,
  });

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'name': name,
        'members': members,
        'groupAdminId': groupAdminId,
      };

  factory Group.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data()! as Map<String, dynamic>;
    return Group(
        groupId: data['groupId'],
        name: data['name'],
        members: data['members'],
        groupAdminId: data['groupAdminId']);
  }
}
