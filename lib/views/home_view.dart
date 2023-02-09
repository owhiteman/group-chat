import 'package:flutter/material.dart';
import 'package:group_chat/firebase/auth_service.dart';
import 'package:group_chat/firebase/firestore_methods.dart';
import 'package:group_chat/models/user.dart';
import 'package:group_chat/views/group_chat_view.dart';
import 'package:group_chat/widgets/button.dart';
import 'package:group_chat/widgets/error_message.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    User? user = context.watch<User?>();
    return user == null
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            body: user.groupId != null
                ? GroupChatView(user: user)
                : Center(
                    child: Column(
                      children: [
                        AppBar(
                          title: const Text('Home'),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(user.name),
                        CustomButton(
                            inputText: 'Join Group',
                            onPressed: () {
                              showDialog(
                                  context: context, builder: joinGroupDialog);
                            }),
                        const SizedBox(height: 20),
                        CustomButton(
                            inputText: 'Create Group',
                            onPressed: () {
                              showDialog(
                                  context: context, builder: createGroupDialog);
                            }),
                        const SizedBox(height: 20),
                        CustomButton(
                          inputText: 'Logout',
                          onPressed: () {
                            context.read<AuthService>().signOut();
                          },
                        ),
                      ],
                    ),
                  ),
          );
  }

  Widget createGroupDialog(BuildContext context) {
    TextEditingController groupName = TextEditingController();
    return AlertDialog(
      title: const Text('Create Group'),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: groupName,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                ),
                textCapitalization: TextCapitalization.words,
                maxLength: 20,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              inputText: 'Create',
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);

                if (groupName.text.isNotEmpty) {
                  var res = await FireStoreMethods()
                      .createGroup(groupName.text.trim());

                  nav.pop();

                  if (res != 'success') {
                    scaffoldMessenger.showSnackBar(SnackBar(
                      content: ErrorMessage(errorText: res),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ));
                  }
                } else {
                  scaffoldMessenger.showSnackBar(const SnackBar(
                    content:
                        ErrorMessage(errorText: 'Please enter a group name'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ));
                }
              },
              width: 110,
            ),
            const SizedBox(
              width: 15,
            ),
            CustomButton(
              inputText: 'Cancel',
              onPressed: () => Navigator.pop(context),
              width: 110,
            )
          ],
        )
      ],
    );
  }

  Widget joinGroupDialog(BuildContext context) {
    TextEditingController groupId = TextEditingController();
    return AlertDialog(
      title: const Text('Join Group'),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: groupId,
                decoration: const InputDecoration(
                  labelText: 'Group ID',
                ),
                textCapitalization: TextCapitalization.words,
              ),
            ],
          ),
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              inputText: 'Join',
              onPressed: () async {
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final nav = Navigator.of(context);

                if (groupId.text.isNotEmpty) {
                  var res =
                      await FireStoreMethods().joinGroup(groupId.text.trim());

                  nav.pop();

                  if (res != 'success') {
                    scaffoldMessenger.showSnackBar(SnackBar(
                      content: ErrorMessage(errorText: res),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ));
                  }
                } else {
                  scaffoldMessenger.showSnackBar(const SnackBar(
                    content: ErrorMessage(errorText: 'Please enter a group ID'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ));
                }
              },
              width: 110,
            ),
            const SizedBox(
              width: 15,
            ),
            CustomButton(
              inputText: 'Cancel',
              onPressed: () => Navigator.pop(context),
              width: 110,
            )
          ],
        )
      ],
    );
  }
}
