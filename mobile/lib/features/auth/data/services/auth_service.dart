import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final Dio _dio = ApiService().dio;
  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '119959634609-e7ljfkdebja9pomisdo08s2qne4l2qls.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
  }

  // 1. Login with Google -> Our Backend
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      debugPrint("Google Sign-In: Initializing...");
      await _ensureGoogleSignInInitialized();
      
      debugPrint("Google Sign-In: Triggering account picker...");
      // In 7.2.0, use authenticate() instead of signIn()
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      
      if (googleUser == null) {
        debugPrint("Google Sign-In: Cancelled by user.");
        return null;
      }

      debugPrint("Google Sign-In: Success. Getting tokens...");
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("Google Sign-In: Could not obtain idToken.");
        return null;
      }

      debugPrint("Google Sign-In: Sending idToken to backend...");
      final response = await _dio.post('/api/auth/google', data: {'idToken': idToken});

      if (response.statusCode == 200 && response.data is Map) {
        return response.data['user'];
      }
      
      debugPrint("Google Sign-In: Backend error: ${response.data}");
      return null;
    } catch (e) {
      debugPrint("Google Sign-In Exception: $e");
      return null;
    }
  }

  // 2. Login with Email/Password -> Our Backend
  Future<Map<String, dynamic>?> signInWithEmail(String email, String password) async {
    try {
      debugPrint("Email Login: Sending request for $email...");
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      debugPrint("Email Login: Backend response status: ${response.statusCode}");
      if (response.statusCode == 200 && response.data is Map) {
        return response.data['user'];
      }
      
      _handleDioError(response);
      return null;
    } catch (e) {
      debugPrint("Email Login Exception: $e");
      return null;
    }
  }

  // 3. Register (Activate Account)
  Future<bool> register(String email, String password) async {
    try {
      debugPrint("Registration: Activating account for $email...");
      final response = await _dio.post('/api/auth/register', data: {
        'email': email,
        'password': password,
      });

      debugPrint("Registration: Backend response status: ${response.statusCode}");
      if (response.statusCode == 200) return true;
      
      _handleDioError(response);
      return false;
    } catch (e) {
      debugPrint("Registration Exception: $e");
      return false;
    }
  }

  // 4. Sign Out
  Future<void> signOut() async {
    try {
      await _dio.post('/api/auth/logout');
      await _googleSignIn.signOut();
    } catch (e) {
      debugPrint("SignOut Error: $e");
    }
  }

  void _handleDioError(Response response) {
    String msg = "Unknown error";
    if (response.data is Map) {
      msg = response.data['error'] ?? msg;
    }
    debugPrint("Auth API Error: $msg");
  }
}
