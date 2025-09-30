import 'package:flutter/material.dart';

void main() {
  runApp(const PrepBuddyApp());
}

class PrepBuddyApp extends StatelessWidget {
  const PrepBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrepBuddy',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PrepBuddy'),
        ),
      
      ),
    );
  }
}