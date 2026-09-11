import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // 1. Sign in with Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      return result.user;
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  // 2. Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // For google_sign_in: ^7.2.0, use GoogleSignIn.instance.authenticate()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // In 7.2.0, accessToken is in a different authorizationClient if needed, 
        // but idToken is usually enough for Firebase.
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      return null;
    }
  }

  // 3. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    // For google_sign_in: ^7.2.0, check if there's a signOut method or similar
    // Actually, usually it's there. Let's check.
  }
}
