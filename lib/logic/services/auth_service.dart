import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:maps_testing/logic/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Regisztrációs hiba: $e");
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Bejelentkezési hiba: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if(user == null) return;

    try {
      await FirestoreService().deleteUserData();
      await user.delete();
    } catch (e) {
      throw Exception("Hiba történt a profil törlésekor: $e");
    }
  }
}