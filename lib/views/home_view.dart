import 'package:flutter/material.dart';
import 'package:group_chat/firebase/auth_service.dart';
import 'package:group_chat/widgets/button.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: CustomButton(
          inputText: 'Logout',
          onPressed: () {
            context.read<AuthService>().signOut();
          },
        ),
      ),
    );
  }
}
