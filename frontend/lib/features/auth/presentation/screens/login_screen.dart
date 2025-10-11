import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:frontend/features/auth/presentation/screens/signup_screen.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/features/auth/presentation/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

// --- GOOGLE SIGN-IN SERVICE CLASS ---

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool isInitialize = false;

  // A one-time initialization for Google Sign-In with your server client ID.
  static Future<void> initSignIn() async {
    if (!isInitialize) {
      
      await _googleSignIn.initialize(
        serverClientId: '887744791735-och61t1j0vk71drdlcb7ohbof9rpuk9l.apps.googleusercontent.com',
      );
      isInitialize = true;
    }
  }

  // --- Sign in with Google ---
  // Handles the entire flow: Google Auth -> Firebase Credential -> Firebase Sign-In -> Firestore User Creation
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      await initSignIn(); // Ensure Google Sign-In is initialized.

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();

      if (googleUser == null) {
        
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      
      // The idToken is sufficient for Firebase authentication.
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      // After successful sign-in, check for user data in Firestore.
      // If the user is new, create a new document for them.
      if (user != null) {
        final userDoc =
            FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();

        if (!docSnapshot.exists) {
          // Try to split the displayName into first and last names
          final nameParts = user.displayName?.split(RegExp(r'\s+')) ?? [];
          final String firstName = nameParts.isNotEmpty ? nameParts.first : '';
          final String lastName =
              nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

          await userDoc.set({
            'firstName': firstName,
            'lastName': lastName,
            'mobileNumber': '', 
            'email': user.email ?? '',

            'uid': user.uid,
            'photoURL': user.photoURL ?? '',
            'provider': 'google', // To identify how the user signed up
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return userCredential;
    } catch (e) {
      // Rethrow the error to be caught by the UI.
      print('Error during Google Sign-In: $e');
      rethrow;
    }
  }

  // --- Sign out ---
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // --- Get current user ---
  static User? getCurrentUser() {
    return _auth.currentUser;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- GOOGLE SIGN-IN (UPDATED) ---
  Future<void> _signInWithGoogle() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Call the static signInWithGoogle method from our service class
      final userCredential = await GoogleSignInService.signInWithGoogle();

      // If sign in is successful and the widget is still mounted
      if (userCredential != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else if (mounted) {
        // This handles the case where the user cancels the sign-in flow
        Navigator.of(context).pop(); // Close the loading dialog
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In Failed: ${e.toString()}")),
        );
      }
    }
  }

  // --- EMAIL SIGN-IN (Unchanged) ---
  Future<void> _signInUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Login Failed")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFFF46D3A);
    const Color backgroundColor = Color(0xFFFFF6F0);
    const Color textFieldColor = Color(0xFFFDF0E7);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Login here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Welcome back you've\nbeen missed!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: textFieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: textFieldColor,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: primaryColor, width: 2.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Forgot your password?',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signInUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  child: const Text(
                    'Sign in',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Create new account',
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Center(
                  child: Text(
                    'Or continue with',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSocialIcon(
                      FontAwesomeIcons.google,
                      onPressed: _signInWithGoogle, // This now calls the updated method
                    ),
                    const SizedBox(width: 20),
                    _buildSocialIcon(
                      FontAwesomeIcons.facebookF,
                      onPressed: () {},
                    ),
                    const SizedBox(width: 20),
                    _buildSocialIcon(FontAwesomeIcons.apple, onPressed: () {}),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: FaIcon(icon, color: Colors.grey[800], size: 24),
      ),
    );
  }
}


