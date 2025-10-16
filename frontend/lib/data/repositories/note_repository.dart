import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:frontend/data/models/note_model.dart';

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // ✅ IMPORTANT: We will store notes in a user-specific box
  // This prevents one user's notes from appearing if another user logs in
  Box<Note> get _notesBox => Hive.box<Note>('notesBox');

  // ✅ CHANGE 1: The method now REQUIRES the user's ID
  Future<List<Note>> getNotes(String userId) async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    final bool isOnline = connectivityResult != ConnectivityResult.none;

    if (isOnline) {
      print("🌐 App is online. Fetching from Firestore for user $userId...");
      try {
        // ✅ CHANGE 2: Use the CORRECT path to the user's notes subcollection
        final querySnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notes')
            .orderBy('timestamp', descending: true) // Ensure you use 'timestamp'
            .get();

        final firestoreNotes = querySnapshot.docs.map((doc) {
          return Note.fromFirestore(doc.data(), doc.id);
        }).toList();

        // Update local cache
        await _notesBox.clear(); // Clear old data
        // Use a map for efficient lookups by ID
        final Map<String, Note> notesMap = {for (var note in firestoreNotes) note.id: note};
        await _notesBox.putAll(notesMap);
        print("✅ Cached ${firestoreNotes.length} notes locally.");

        return firestoreNotes;
      } catch (e) {
        print("🔥 Firestore fetch failed, falling back to cache. Error: $e");
        return _notesBox.values.toList();
      }
    } else {
      print("🔌 App is offline. Fetching from Hive cache...");
      return _notesBox.values.toList();
    }
  }

  // ✅ CHANGE 3: Update this method to be user-aware
  Future<void> addOrUpdateNote(String userId, Note note) async {
    // Immediately save to the local cache for a snappy UI
    await _notesBox.put(note.id, note);
    print("✅ Saved note '${note.id}' to local Hive cache.");

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notes')
            .doc(note.id)
            .set(note.toFirestore()); // `set` handles both create and update
        print("✅ Synced note '${note.id}' to Firestore.");
      } catch (e) {
        print("🔥 Firestore sync failed, but it's saved locally. Error: $e");
      }
    }
  }

  // ✅ CHANGE 4: Update this method to be user-aware
  Future<void> deleteNote(String userId, String noteId) async {
    // Delete from local cache first
    await _notesBox.delete(noteId);

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notes')
            .doc(noteId)
            .delete();
      } catch (e) {
        print("Firestore delete failed. Error: $e");
      }
    }
  }
}