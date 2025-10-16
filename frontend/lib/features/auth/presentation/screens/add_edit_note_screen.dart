// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:frontend/data/models/note_model.dart';
// import 'package:frontend/data/repositories/note_repository.dart';

// class AddEditNoteScreen extends StatefulWidget {
//   final Note? note; // Pass the note document if editing

//   const AddEditNoteScreen({super.key, this.note});

//   @override
//   State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
// }

// class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
//   final _titleController = TextEditingController();
//   final _contentController = TextEditingController();
//   final _currentUser = FirebaseAuth.instance.currentUser;
//    final NoteRepository _noteRepository = NoteRepository();

//   @override
//   void initState() {
//     super.initState();
//     // If we are editing a note, pre-fill the text fields
//     if (widget.note != null) {
//      _titleController.text = widget.note!.title;
//     _contentController.text = widget.note!.content;
//     }
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   // Function to save or update the note
// void _saveNote() async {
//     final title = _titleController.text.trim();
//     final content = _contentController.text.trim();

//     final userId = FirebaseAuth.instance.currentUser?.uid;
//   if (userId == null) {
//       print("❌ Error: User is not logged in. Cannot save note.");
//       return;
//   }

//     if (title.isEmpty || content.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Title and content cannot be empty.')),
//       );
//       return;
//     }

//     final String noteId = widget.note?.id ?? FirebaseFirestore.instance.collection('p').doc().id;

//   final Note noteToSave = Note(
//     id: noteId,
//     title: title,
//     content: content,
//     timestamp: DateTime.now(),
//   );

//   // ✅ PASS THE USER ID HERE
//   await _noteRepository.addOrUpdateNote(userId, noteToSave);

//   if (mounted) {
//     Navigator.of(context).pop();
//   }a
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
//         backgroundColor: const Color(0xFFF46D3A),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.save),
//             onPressed: _saveNote,
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _titleController,
//               decoration: const InputDecoration(
//                 labelText: 'Title',
//                 border: OutlineInputBorder(),
//               ),
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: TextField(
//                 controller: _contentController,
//                 maxLines: null, // Allows the text field to expand
//                 expands: true,
//                 textAlignVertical: TextAlignVertical.top,
//                 decoration: const InputDecoration(
//                   labelText: 'Content',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:frontend/data/models/note_model.dart';
import 'package:frontend/data/repositories/note_repository.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final NoteRepository _noteRepository = NoteRepository();

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A title is required to save the note.')),
      );
      return;
    }
    if (userId == null) return;

    final String noteId =
        widget.note?.id ?? FirebaseFirestore.instance.collection('p').doc().id;

    final Note noteToSave = Note(
      id: noteId,
      title: title,
      content: content,
      timestamp: DateTime.now(),
    );

    await _noteRepository.addOrUpdateNote(userId, noteToSave);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Add Note' : 'Edit Note'),
        backgroundColor: const Color(0xFFF46D3A),
        // ✅ Make the AppBar flat for a modern look
        elevation: 0,
        actions: [
          IconButton(
            // ✅ Use a cleaner icon for saving
            icon: const Icon(Icons.check),
            tooltip: 'Save Note',
            onPressed: _saveNote,
          ),
        ],
      ),
      // ✅ Use a clean white background for the body
      backgroundColor: Colors.white,
      body: Padding(
        // ✅ Add more horizontal padding for better spacing
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          children: [
            // --- STYLED TITLE FIELD ---
            TextField(
              controller: _titleController,
              // ✅ Make the title text larger and bolder
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: const InputDecoration(
                // ✅ Remove the border
                border: InputBorder.none,
                // ✅ Style the hint text to match the input style
                hintText: 'Title',
                hintStyle: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC9C9C9),
                ),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 10), // A little space between fields
            // --- STYLED CONTENT FIELD ---
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                // ✅ Use a professional-looking style for the body text
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  height: 1.5, // Improve line spacing for readability
                ),
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  // ✅ Remove the border
                  border: InputBorder.none,
                  hintText: 'Start writing your note here...',
                  hintStyle: TextStyle(fontSize: 18, color: Color(0xFFC9C9C9)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
