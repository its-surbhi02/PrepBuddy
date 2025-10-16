// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;

// const String _apiKey = "AIzaSyAzJvCu4Eij8VhtJypO2HJnpxtO2XsW8mc";

// class AiToolsScreen extends StatefulWidget {
//   const AiToolsScreen({super.key});

//   @override
//   State<AiToolsScreen> createState() => _AiToolsScreenState();
// }

// class _AiToolsScreenState extends State<AiToolsScreen> {
//   final TextEditingController _promptController = TextEditingController();
//   String _response = "Your AI response will appear here...";
//   bool _isLoading = false;

//   /// Makes the API call to the Google Gemini API.
//   Future<void> _generateContent() async {
//     if (_apiKey == "AIzaSyAzJvCu4Eij8VhtJypO2HJnpxtO2XsW8mc") {
//       setState(() {
//         _response =
//             "Please add your Gemini API key to the code.\n\nGet your key from Google AI Studio.";
//       });
//       return;
//     }

//     if (_promptController.text.isEmpty) {
//       // Show a snackbar or some other feedback if the prompt is empty
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please enter a prompt first.'),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//       _response = "Thinking...";
//     });

//     final url = Uri.parse(
//         'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');

//     final requestBody = jsonEncode({
//       "contents": [
//         {
//           "parts": [
//             {"text": _promptController.text}
//           ]
//         }
//       ]
//     });

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: requestBody,
//       );

//       if (response.statusCode == 200) {
//         final responseBody = jsonDecode(response.body);
//         // Navigate through the JSON to get the text part of the response.
//         // Make sure to handle potential nulls or errors in the response structure.
//         final text = responseBody['candidates'][0]['content']['parts'][0]['text'];
//         setState(() {
//           _response = text;
//         });
//       } else {
//         // Handle API errors gracefully
//         final errorBody = jsonDecode(response.body);
//         final errorMessage = errorBody['error']?['message'] ?? 'Unknown API Error';
//         setState(() {
//           _response = "Error: ${response.statusCode}\n$errorMessage";
//         });
//       }
//     } catch (e) {
//       // Handle network or other exceptions
//       setState(() {
//         _response = "Failed to make request. Check your connection or API key.\nError: $e";
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F4F8), // Light grey-blue background
//       appBar: AppBar(
//         title: const Text(
//           'Gemini AI Assistant',
//           style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
//         ),
//         backgroundColor: const Color(0xFF4A90E2), // A nice blue for the app bar
//         elevation: 2,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Response Area
//             Expanded(
//               child: Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Container(
//                   padding: const EdgeInsets.all(16.0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text(
//                               "AI Response",
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF4A90E2),
//                               ),
//                             ),
//                             // Copy button
//                             if (_response.isNotEmpty && _response != "Your AI response will appear here..." && !_isLoading)
//                               IconButton(
//                                 icon: const Icon(Icons.copy_all_outlined, color: Colors.grey),
//                                 tooltip: 'Copy Response',
//                                 onPressed: () {
//                                   Clipboard.setData(ClipboardData(text: _response));
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     const SnackBar(
//                                       content: Text('Response copied to clipboard!'),
//                                       backgroundColor: Colors.green,
//                                     ),
//                                   );
//                                 },
//                               ),
//                           ],
//                         ),
//                         const Divider(height: 20),
//                         // Display the response or loading indicator
//                         _isLoading
//                             ? const Center(
//                                 child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   CircularProgressIndicator(),
//                                   SizedBox(height: 16),
//                                   Text("Generating..."),
//                                 ],
//                               ))
//                             : SelectableText(
//                                 _response,
//                                 style: const TextStyle(fontSize: 16, height: 1.5),
//                               ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Input Area
//             Card(
//               elevation: 2,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _promptController,
//                         decoration: const InputDecoration(
//                           hintText: 'Enter your prompt here...',
//                           border: InputBorder.none,
//                           contentPadding: EdgeInsets.all(12),
//                         ),
//                         maxLines: null, // Allows multiline input
//                         keyboardType: TextInputType.multiline,
//                       ),
//                     ),
//                     // Send button
//                     IconButton(
//                       icon: _isLoading
//                           ? const SizedBox.shrink() // Hide button icon when loading
//                           : const Icon(
//                               Icons.send,
//                               color: Color(0xFF4A90E2),
//                             ),
//                       onPressed: _isLoading ? null : _generateContent,
//                       tooltip: 'Generate Response',
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _promptController.dispose();
//     super.dispose();
//   }
// }
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

final String apiKey = dotenv.env['API_KEY'] ?? 'API_KEY_NOT_FOUND';

class AiToolsScreen extends StatefulWidget {
  const AiToolsScreen({super.key});

  @override
  State<AiToolsScreen> createState() => _AiToolsScreenState();
}

class _AiToolsScreenState extends State<AiToolsScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  // 💬 Stores chat history
  final List<Map<String, String>> _messages = [];

  /// 🧠 Makes the API call to Gemini 2.5 Flash
  Future<void> _generateContent() async {
    if (_promptController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a prompt first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final prompt = _promptController.text.trim();

    setState(() {
      _messages.add({"role": "user", "text": prompt});
      _isLoading = true;
      _promptController.clear(); // ✅ Clear input after sending
    });

    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1/models/gemini-2.5-flash:generateContent?key=$apiKey",
    );

    final requestBody = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final text = responseBody['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _messages.add({"role": "ai", "text": text});
        });
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['error']?['message'] ?? 'Unknown API Error';
        setState(() {
          _messages.add({
            "role": "ai",
            "text": "Error: ${response.statusCode}\n$errorMessage"
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          "role": "ai",
          "text": "Failed to make request. Check your connection or API key.\nError: $e"
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Auto scroll to latest message
      await Future.delayed(const Duration(milliseconds: 300));
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: const Text(
          ' Your AI Assistant',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 226, 147, 74),
        elevation: 2,
      ),
      body: Column(
        children: [
          // 💬 Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6.0),
                    padding: const EdgeInsets.all(12.0),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? const Color(0xFF4A90E2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: SelectableText(
                      msg["text"] ?? "",
                      style: TextStyle(
                        fontSize: 15,
                        color: isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 📝 Input bar
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _generateContent(),
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send, color: Color(0xFF4A90E2)),
                  onPressed: _isLoading ? null : _generateContent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
