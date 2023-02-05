import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:group_chat/firebase/auth_service.dart';
import 'package:group_chat/models/user.dart' as model;
import 'package:group_chat/views/home_view.dart';
import 'package:group_chat/views/login_view.dart';
import 'package:group_chat/views/register_view.dart';
import 'package:provider/provider.dart';

import 'firebase/firebase_options.dart';
import 'firebase/firestore_methods.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider(
          create: (context) => context.read<AuthService>().authStateChanges,
          initialData: null,
        ),
        Provider<AuthService>(
          create: (_) => AuthService(FirebaseAuth.instance),
        ),
      ],
      child: MaterialApp(
        title: 'Group Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthenticationWrapper(),
        routes: {
          '/login': (context) => const LoginView(),
          '/register': (context) => const RegisterView(),
        },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Something went wrong'),
            );
          } else if (snapshot.hasData) {
            return StreamProvider<model.User?>(
              create: (_) => FireStoreMethods().user,
              initialData: null,
              child: const HomeView(),
            );
          } else {
            return const LoginView();
          }
        },
      ),
    );
  }
}
