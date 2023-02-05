class Group {
  final String groupId;
  final String name;
  final List members;
  final String groupAdminId;
  final List<String> messages;

  Group({
    required this.groupId,
    required this.name,
    required this.members,
    required this.groupAdminId,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
        'groupId': groupId,
        'name': name,
        'members': members,
        'groupAdminId': groupAdminId,
        'messages': messages
      };
}
