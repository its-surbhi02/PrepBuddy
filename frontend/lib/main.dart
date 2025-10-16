import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/data/models/note_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'features/auth/presentation/screens/login_screen.dart';
import 'firebase_options.dart';

// Handle background FCM messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

// Global local notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Hive
  await Hive.initFlutter();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Register your model adapter
  Hive.registerAdapter(NoteAdapter());

  // Open the box where you'll store notes
  await Hive.openBox<Note>('notesBox');

  // Initialize the local notifications plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Create Android notification channel (required on Android 13+)
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Must match the ID used in NotificationDetails
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize Google Mobile Ads
  MobileAds.instance.initialize();

  // Register FCM background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Configure Crashlytics error handling
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const PrepBuddyApp());
}

class PrepBuddyApp extends StatefulWidget {
  const PrepBuddyApp({super.key});

  @override
  State<PrepBuddyApp> createState() => _PrepBuddyAppState();
}

class _PrepBuddyAppState extends State<PrepBuddyApp> {
  @override
  void initState() {
    super.initState();
     _getFCMToken();
    setupFCM();
  }
  
   Future<void> _getFCMToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('=======================================');
    print('FCM Token: $fcmToken');
    print('=======================================');
    // You can now send this token to your server or use it for testing.
  }
  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // iOS foreground presentation options (no effect on Android)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Request notification permission (Android 13+ and iOS)
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Subscribe to a topic for general alerts
    await messaging.subscribeToTopic("news_alerts");
    print("Subscribed to 'news_alerts' topic");

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground');
      RemoteNotification? notification = message.notification;

      if (notification != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });

    // Notification tap handler
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('User tapped on a notification!');
      if (message.data['screen'] == 'offers') {
        print("Navigating to the offers screen...");
        // Example navigation:
        // Navigator.of(context).pushNamed('/offers');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'PrepBuddy',
      home: LoginScreen(),
    );
  }
}
