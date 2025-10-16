// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart'; // Import Remote Config

// // --- Screen Imports (Ensure these paths are correct for your project) ---
// import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
// import 'package:frontend/features/auth/presentation/screens/add_edit_note_screen.dart';
// import 'package:frontend/features/auth/presentation/screens/ads_screen.dart';
// import 'package:frontend/features/auth/presentation/screens/aitools_screen.dart';
// import 'package:frontend/features/auth/presentation/screens/payment_screen.dart';
// import 'package:frontend/features/auth/presentation/screens/settings_page.dart';

// // --- Main HomeScreen Widget ---
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   User? _user;
//   Future<DocumentSnapshot<Map<String, dynamic>>>? _userDataFuture;
//   Stream<QuerySnapshot>? _notesStream;

//   // --- Remote Config State ---
//   final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
//   String _appBarTitle = "My Notes"; // Default title

//   @override
//   void initState() {
//     super.initState();
//     _user = FirebaseAuth.instance.currentUser;
//     if (_user != null) {
//       _userDataFuture = _fetchUserData(_user!.uid);
//       // Initialize the stream to fetch the user's notes
//       _notesStream = FirebaseFirestore.instance
//           .collection('users')
//           .doc(_user!.uid)
//           .collection('notes')
//           .orderBy('createdAt', descending: true) // Show newest notes first
//           .snapshots();
//     }
//     // Initialize and fetch Remote Config values
//     _initializeRemoteConfig();
//   }

//   // --- Initialize and Fetch Remote Config ---
//  Future<void> _initializeRemoteConfig() async {
//   try {
//     await _remoteConfig.setConfigSettings(RemoteConfigSettings(
//       fetchTimeout: const Duration(minutes: 1),
//       minimumFetchInterval: Duration.zero,
//     ));

//     // ✅ Add defaults before fetching
//     await _remoteConfig.setDefaults({
//       'app_bar_title': 'My....',
//       'refresh_interval': 60,
//     });

//     await _remoteConfig.fetchAndActivate();

//     final String fetchedTitle = _remoteConfig.getString('app_bar_title');
//     print("✅ Remote Config fetched: '$fetchedTitle'");

//     if (mounted) {
//       setState(() {
//         _appBarTitle = fetchedTitle;
//       });
//     }
//   } catch (e) {
//     print("❌ Error initializing remote config: $e");
//   }
// }







//   Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData(String uid) {
//     return FirebaseFirestore.instance.collection('users').doc(uid).get();
//   }

//   // --- Function to delete a note from Firestore ---
//   void _deleteNote(String noteId) {
//     if (_user == null) return;
//     FirebaseFirestore.instance
//         .collection('users')
//         .doc(_user!.uid)
//         .collection('notes')
//         .doc(noteId)
//         .delete();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_appBarTitle), // Use the dynamic title from Remote Config!
//         backgroundColor: const Color(0xFFF46D3A),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout),
//             onPressed: () async {
//               await FirebaseAuth.instance.signOut();
//               if (mounted) {
//                 Navigator.of(context).pushAndRemoveUntil(
//                   MaterialPageRoute(builder: (context) => const LoginScreen()),
//                   (Route<dynamic> route) => false,
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//               future: _userDataFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return UserAccountsDrawerHeader(
//                     accountName: const Text("Loading..."),
//                     accountEmail: Text(_user?.email ?? 'Loading...'),
//                     decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
//                   );
//                 }
//                 if (!snapshot.hasData || snapshot.hasError) {
//                   return UserAccountsDrawerHeader(
//                     accountName: const Text("User Name"),
//                     accountEmail: Text(_user?.email ?? 'user@example.com'),
//                     decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
//                   );
//                 }
//                 final userData = snapshot.data!.data();
//                 final firstName = userData?['firstName'] ?? '';
//                 final lastName = userData?['lastName'] ?? '';
//                 final fullName = '$firstName $lastName'.trim();
//                 return UserAccountsDrawerHeader(
//                   accountName: Text(fullName.isNotEmpty ? fullName : "User Name"),
//                   accountEmail: Text(_user?.email ?? 'user@example.com'),
//                   currentAccountPicture: CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Text(
//                       firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'U',
//                       style: const TextStyle(fontSize: 40.0, color: Color(0xFFF46D3A)),
//                     ),
//                   ),
//                   decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.ad_units),
//               title: const Text('Show Ads'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const AdsScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.payment),
//               title: const Text('Go Premium'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.smart_toy),
//               title: const Text('AI Tools'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const AiToolsScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.settings),
//               title: const Text('Show Test Crash'),
//               onTap: () {
//                 Navigator.pop(context);
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
//               },
//             ),
//           ],
//         ),
//       ),
//       // --- BODY: Replaced with a StreamBuilder to display notes ---
//       body: StreamBuilder<QuerySnapshot>(
//         stream: _notesStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return const Center(child: Text('Something went wrong.'));
//           }
//           if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[400]),
//                   const SizedBox(height: 16),
//                   Text(
//                     'No notes yet.',
//                     style: TextStyle(fontSize: 22, color: Colors.grey[600]),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Tap the '+' button to add your first note!",
//                     style: TextStyle(fontSize: 16, color: Colors.grey[500]),
//                   ),
//                 ],
//               ),
//             );
//           }

//           final notes = snapshot.data!.docs;
//           return ListView.builder(
//             itemCount: notes.length,
//             itemBuilder: (context, index) {
//               final note = notes[index];
//               return Dismissible(
//                 key: Key(note.id), // Unique key for each item
//                 direction: DismissDirection.endToStart,
//                 onDismissed: (direction) {
//                   _deleteNote(note.id);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Note deleted')),
//                   );
//                 },
//                 background: Container(
//                   color: Colors.red,
//                   alignment: Alignment.centerRight,
//                   padding: const EdgeInsets.symmetric(horizontal: 20),
//                   child: const Icon(Icons.delete, color: Colors.white),
//                 ),
//                 child: Card(
//                   margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   child: ListTile(
//                     title: Text(note['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
//                     subtitle: Text(
//                       note['content'],
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     onTap: () {
//                       // Navigate to edit the existing note
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => AddEditNoteScreen(note: note),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Navigate to create a new note
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => const AddEditNoteScreen(),
//             ),
//           );
//         },
//         backgroundColor: const Color(0xFFF46D3A),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }

// // --- Placeholder Widgets (to make the file runnable) ---
// // (These would normally be in their own files)

import 'dart:async'; 
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'package:frontend/data/models/note_model.dart';
import 'package:frontend/data/repositories/note_repository.dart';

import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/auth/presentation/screens/add_edit_note_screen.dart';

import 'package:frontend/features/auth/presentation/screens/aitools_screen.dart';
import 'package:frontend/features/auth/presentation/screens/payment_screen.dart';
import 'package:frontend/features/auth/presentation/screens/settings_page.dart';
import 'package:frontend/features/auth/presentation/screens/ads_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _userDataFuture;
  final NoteRepository _noteRepository = NoteRepository();


  Future<List<Note>> _notesFuture = Future.value([]);

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  String _appBarTitle = "My Notes";

  //  subscription variable to manage the auth listener
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initializeRemoteConfig();

    // authentication state changes for a robust UI
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (!mounted) return; // Don't do anything if the widget is no longer visible

      if (user == null) {
        // If user logs out, navigate to the LoginScreen
        print('User is currently signed out!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        // If user is logged in, update state and fetch their data
        print('User is signed in!');
        setState(() {
          _user = user;
          _userDataFuture = _fetchUserData(user.uid);
          _refreshNotes(); // Fetch notes for the new user
        });
      }
    });
  }

  @override
  void dispose() {
    // ✅ 5. Cancel the subscription to prevent memory leaks when the screen is closed
    _authSubscription?.cancel();
    super.dispose();
  }
  
  void _refreshNotes() {
    if (_user != null) {
      setState(() {
        _notesFuture = _noteRepository.getNotes(_user!.uid);
      });
    }
  }

  Future<void> _deleteNote(String noteId) async {
    if (_user != null) {
      await _noteRepository.deleteNote(_user!.uid, noteId);
      _refreshNotes();
    }
  }

  void _navigateToAddEditNote({Note? note}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditNoteScreen(note: note),
      ),
    ).then((_) {
      // When we return from the Add/Edit screen, refresh the notes list
      _refreshNotes();
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Future<void> _initializeRemoteConfig() async {
    // Your existing remote config code...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: const Color(0xFFF46D3A),
        actions: [
          // This logout button is still fine, but the listener provides a safety net
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      // ... Your drawer code remains the same ...
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return UserAccountsDrawerHeader(
                    accountName: const Text("Loading..."),
                    accountEmail: Text(_user?.email ?? 'Loading...'),
                    decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
                  );
                }
                if (!snapshot.hasData || snapshot.hasError) {
                  return UserAccountsDrawerHeader(
                    accountName: const Text("User Name"),
                    accountEmail: Text(_user?.email ?? 'user@example.com'),
                    decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
                  );
                }
                final userData = snapshot.data!.data();
                final firstName = userData?['firstName'] ?? '';
                final lastName = userData?['lastName'] ?? '';
                final fullName = '$firstName $lastName'.trim();
                return UserAccountsDrawerHeader(
                  accountName: Text(fullName.isNotEmpty ? fullName : "User Name"),
                  accountEmail: Text(_user?.email ?? 'user@example.com'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      firstName.isNotEmpty ? firstName.substring(0, 1).toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 40.0, color: Color(0xFFF46D3A)),
                    ),
                  ),
                  decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.ad_units),
              title: const Text('Show Ads'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Go Premium'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PaymentScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.smart_toy),
              title: const Text('AI Tools'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AiToolsScreen()));
              },
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Note>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          // ... The rest of your FutureBuilder and UI code remains exactly the same ...
          if (snapshot.connectionState == ConnectionState.waiting && _user != null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text(
                    'No notes yet.',
                    style: TextStyle(fontSize: 22, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap the '+' button to add your first note!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          final notes = snapshot.data!;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Dismissible(
                key: Key(note.id),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  _deleteNote(note.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Note deleted')),
                  );
                },
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      note.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      _navigateToAddEditNote(note: note);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddEditNote,
        backgroundColor: const Color(0xFFF46D3A),
        child: const Icon(Icons.add),
      ),
    );
  }
}