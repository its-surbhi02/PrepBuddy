import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/features/auth/presentation/screens/login_screen.dart';
// import 'package:frontend/features/auth/presentation/screens/ads_screen.dart';
// import 'package:frontend/features/auth/presentation/screens/payment_screen.dart';
import 'package:frontend/features/auth/presentation/screens/ads_screen.dart';
import 'package:frontend/features/auth/presentation/screens/aitools_screen.dart';

// --- Main HomeScreen Widget ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _userDataFuture;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    // If a user is logged in, trigger the fetch for their data
    if (_user != null) {
      _userDataFuture = _fetchUserData(_user!.uid);
    }
  }

  // Function to fetch the user's document from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        backgroundColor: const Color(0xFFF46D3A),
        actions: [
          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // Navigate back to LoginScreen and remove all previous routes
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              }
            },
          ),
        ],
      ),
      // --- The Slide-out Navigation Drawer ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            // Header that displays user info fetched from Firestore
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: _userDataFuture,
              builder: (context, snapshot) {
                // While loading, show a placeholder
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return UserAccountsDrawerHeader(
                    accountName: const Text("Loading..."),
                    accountEmail: Text(_user?.email ?? 'Loading...'),
                    decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
                  );
                }

                // If there's an error or no data
                if (!snapshot.hasData || snapshot.hasError) {
                  return UserAccountsDrawerHeader(
                    accountName: const Text("User Name"),
                    accountEmail: Text(_user?.email ?? 'user@example.com'),
                    decoration: const BoxDecoration(color: Color(0xFFF46D3A)),
                  );
                }

                // When data is fetched successfully
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
            // Navigation items
            ListTile(
              leading: const Icon(Icons.ad_units),
              title: const Text('Show Ads'),
              onTap: () {
                Navigator.pop(context); // Close the drawer first
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
      // --- Main content of the screen (placeholder for notes list) ---
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No notes yet.',
              style: TextStyle(fontSize: 22, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              "Tap the '+' button to add your first note!",
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
      // --- Button to add a new note ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to the Add/Edit Note screen
        },
        backgroundColor: const Color(0xFFF46D3A),
        child: const Icon(Icons.add),
      ),
    );
  }
}


class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium Features')),
      body: const Center(child: Text('Payment options will be shown here')),
    );
  }
}

