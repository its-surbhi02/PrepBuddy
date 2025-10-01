import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/features/auth/presentation/screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


// Remember to dispose controllers to free up resources
   @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

// Create the sign-up function
   Future<void> _signUpUser() async {
    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      // Show an error message if passwords don't match
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return; // Stop the function
    }


    try {
      //  First, create the user with Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 5. AFTER creating the user, store their additional data in Firestore
      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'mobileNumber': _mobileController.text.trim(),
          'email': _emailController.text.trim(),
        });
      }


      // Navigate to HomeScreen on success
      // We check `mounted` to ensure the widget is still in the tree
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Show an error message from Firebase
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    }
  }

  bool _agreeToTerms = false;

  @override
  Widget build(BuildContext context) {
    // Reusing the same color constants
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
                const SizedBox(height: 20),

                // --- Header ---
                const Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 30, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's get you started!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 20, 
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20), 

                // 6. Attach controllers to the TextFields
                _buildTextField(label: 'First Name', controller: _firstNameController),
                const SizedBox(height: 10),
                _buildTextField(label: 'Last Name', controller: _lastNameController),
                const SizedBox(height: 10),
                _buildTextField(label: 'Mobile Number', controller: _mobileController, keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                _buildTextField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _buildTextField(label: 'Password', controller: _passwordController, obscureText: true),
                const SizedBox(height: 10),
                _buildTextField(label: 'Confirm Password', controller: _confirmPasswordController, obscureText: true),
                const SizedBox(height: 14),
                
                // --- Terms and Conditions Checkbox ---
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the terms and conditions',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14), 

                // --- Create Account Button ---
                ElevatedButton(
                  onPressed:  _signUpUser,
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
                    'Create Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10), 

                // --- Sign In Link ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        // Navigate back to the Login Screen
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Sign in',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 7. Modify the helper to accept a controller
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    const Color textFieldColor = Color(0xFFFDF0E7);
    const Color primaryColor = Color(0xFFF46D3A);

    return TextField(
      controller: controller, // Use the controller
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: textFieldColor,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
      ),
    );
  }
}