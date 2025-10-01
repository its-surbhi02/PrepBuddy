import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';

void main() async {
  // Ensure that Flutter's binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform, // This line is added by the FlutterFire CLI
  );
  runApp(const MyApp());
}

class PrepBuddyApp extends StatelessWidget {
  const PrepBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PrepBuddy',
      // Set your LoginScreen as the home screen
      home: MyApp(),
    );
  }
}