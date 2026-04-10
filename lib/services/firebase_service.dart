import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Sign In (Anonymous or Google)
  Future<User?> signIn() async {
     try {
       final userCredential = await _auth.signInAnonymously();
       return userCredential.user;
     } catch (e) {
       print("Firebase Auth Error: $e");
       return null;
     }
  }

  // --- CHAT HISTORY ---
  Future<void> saveChatMessage(String message, String aiResponse, {String? folderId}) async {
      User? user = _auth.currentUser;
      if (user != null) {
          await _firestore.collection('users').doc(user.uid).collection('chats').add({
              'message': message,
              'response': aiResponse,
              'timestamp': FieldValue.serverTimestamp(),
              'pinned': false, 
              'folderId': folderId,
          });
      }
  }

  Stream<QuerySnapshot> getChatHistory({String? folderId}) {
      User? user = _auth.currentUser;
      if (user != null) {
          var query = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('chats');
          
          if (folderId != null) {
            return query.where('folderId', isEqualTo: folderId).orderBy('timestamp', descending: true).snapshots();
          }
          
          return query.orderBy('timestamp', descending: true).snapshots();
      }
      return const Stream.empty();
  }

  // --- FOLDERS ---
  Future<void> createFolder(String name) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).collection('folders').add({
        'name': name,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<QuerySnapshot> getFolders() {
    User? user = _auth.currentUser;
    if (user != null) {
      return _firestore
          .collection('users')
          .doc(user.uid)
          .collection('folders')
          .orderBy('timestamp', descending: false)
          .snapshots();
    }
    return const Stream.empty();
  }

  Future<void> deleteFolder(String folderId) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Delete all chats in the folder first
      final chats = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .where('folderId', isEqualTo: folderId)
          .get();
      for (final doc in chats.docs) {
        await doc.reference.delete();
      }
      // Then delete the folder itself
      await _firestore.collection('users').doc(user.uid).collection('folders').doc(folderId).delete();
    }
  }

  Future<void> signOut() async {
      await _auth.signOut();
  }
}
