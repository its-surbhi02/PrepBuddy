import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
 
  await Firebase.initializeApp(
  );
  runApp(const MyApp());
}

class PrepBuddyApp extends StatelessWidget {
  const PrepBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PrepBuddy',
      // LoginScreen as the home screen
      home: MyApp(),
    );
  }
}