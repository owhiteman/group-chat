import 'package:flutter/material.dart';
import 'package:group_chat/firebase/auth_service.dart';
import 'package:group_chat/firebase/firestore_methods.dart';
import 'package:group_chat/models/user.dart';
import 'package:group_chat/widgets/error_message.dart';
import 'package:provider/provider.dart';

class SidebarNavigationView extends StatefulWidget {
  final User user;
  const SidebarNavigationView({super.key, required this.user});

  @override
  State<SidebarNavigationView> createState() => _SidebarNavigationViewState();
}

class _SidebarNavigationViewState extends State<SidebarNavigationView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50),
            buildHeader(context),
            const SizedBox(height: 10),
            buildProfileItems(context),
            const Divider(color: Colors.black54),
            buildGroupItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(
                  widget.user.displayPicUrl ??
                      "https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg",
                ),
                radius: 40,
              ),
              const SizedBox(height: 10),
              Text(
                widget.user.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
            ],
          );
  }

  Widget buildGroupItems(BuildContext context) {
    return widget.user.groupId == null
        ? Container()
        : Column(
            children: [
              ListTile(
                leading: const Icon(Icons.group_outlined),
                title: const Text('Group members'),
                onTap: () {
                  // TODO Navigator.of(context).pushNamed('/groupMembersView');
                },
              ),
              ListTile(
                leading: const Icon(Icons.directions_walk),
                title: const Text('Leave Group'),
                onTap: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  var res = await FireStoreMethods().leaveGroup(widget.user);
                  if (res != 'success') {
                    scaffoldMessenger.showSnackBar(SnackBar(
                      content: ErrorMessage(errorText: res),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ));
                  }
                },
              ),
            ],
          );
  }

  Widget buildProfileItems(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.logout_outlined),
          title: const Text('Log out'),
          onTap: () {
            context.read<AuthService>().signOut();
          },
        )
      ],
    );
  }
}
