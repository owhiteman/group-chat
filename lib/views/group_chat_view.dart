import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:group_chat/firebase/firestore_methods.dart';
import 'package:group_chat/views/sidebar_nav_view.dart';
import 'package:group_chat/models/user.dart' as models;

class GroupChatView extends StatefulWidget {
  final models.User? user;
  const GroupChatView({super.key, required this.user});

  @override
  State<GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends State<GroupChatView> {
  late final _user = types.User(
    id: widget.user!.uid,
    imageUrl: widget.user!.displayPicUrl,
    firstName: widget.user!.name,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<String>>(
        initialData: const [],
        stream: FireStoreMethods().groupUserIds(widget.user!.groupId!),
        builder: (context, snapshot) => StreamBuilder<List<types.User>>(
          initialData: const [],
          stream: FireStoreMethods().groupAuthorDetails(snapshot.data!),
          builder: (context, snapshot) => StreamBuilder<List<types.Message>>(
            initialData: const [],
            stream: FireStoreMethods()
                .messages(widget.user!.groupId!, snapshot.data!),
            builder: (context, snapshot) => Chat(
              messages: snapshot.data ?? [],
              onSendPressed: _handleSendPressed,
              user: _user,
              theme: const DefaultChatTheme(
                sendButtonIcon: Icon(Icons.send, color: Colors.white),
              ),
              showUserAvatars: true,
              showUserNames: true,
            ),
          ),
        ),
      ),
      drawer: SidebarNavigationView(user: widget.user!),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    FireStoreMethods().sendMessage(message, widget.user!.groupId!);
  }
}
