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
        serverClientId: '119959634609-e7ljfkdebja9pomisdo08s2qne4l2qls.apps.googleusercontent.com',
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
    } on FirebaseAuthException catch (e) {
      debugPrint("Login Error [${e.code}]: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Login Error: $e");
      return null;
    }
  }

  // 1b. Sign up with Email & Password
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Registration Error [${e.code}]: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Registration Error: $e");
      return null;
    }
  }

  // 2. Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      // For google_sign_in: ^7.2.0, use authenticate() instead of signIn()
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      // authentication is not a Future in version 7.x
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      return result.user;
    } on GoogleSignInException catch (e) {
      debugPrint("Google Sign-In Error [${e.code}]: ${e.description}");
      return null;
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
