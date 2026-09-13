import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '465237029545-laq6dh8hibooccngb7c7ud3rhblfcm2t.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
  }

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
      await _ensureGoogleSignInInitialized();
      
      // For google_sign_in: ^7.2.0, use authenticate()
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      
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
    // For google_sign_in: ^7.2.0, signOut is available on the instance
    await _googleSignIn.signOut();
  }
}
