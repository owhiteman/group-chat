import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:group_chat/firebase/firestore_methods.dart';
import 'package:group_chat/views/sidebar_nav_view.dart';
import 'package:uuid/uuid.dart';
import 'package:group_chat/models/user.dart' as models;

class GroupChatView extends StatefulWidget {
  final models.User? user;
  const GroupChatView({super.key, required this.user});

  @override
  State<GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends State<GroupChatView> {
  final List<types.Message> _messages = [];
  late final _user = types.User(
    id: widget.user!.uid,
    imageUrl: widget.user!.displayPicUrl,
    firstName: widget.user!.name,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: StreamBuilder<List<types.Message>>(
        initialData: const [],
        stream: FireStoreMethods().messages(widget.user!.groupId!),
        builder: (context, snapshot) => Chat(
          messages: snapshot.data ?? [],
          onSendPressed: _handleSendPressed,
          user: _user,
          theme: const DefaultChatTheme(
            sendButtonIcon: Icon(Icons.send, color: Colors.white),
          ),
        ),
      ),
      drawer: SidebarNavigationView(user: widget.user!),
    );
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _handleSendPressed(types.PartialText message) {
    // final textMessage = types.TextMessage(
    //   author: _user,
    //   createdAt: DateTime.now().millisecondsSinceEpoch,
    //   id: const Uuid().v4(),
    //   text: message.text,
    // );

    // _addMessage(textMessage);

    FireStoreMethods().sendMessage(message, widget.user!.groupId!);
  }
}
