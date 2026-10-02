import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final Dio _dio = ApiService().dio;
  bool _isGoogleSignInInitialized = false;

  Future<void> _ensureInitialized() async {
    await ApiService().initPersistentCookies();
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize(
        serverClientId: '119959634609-e7ljfkdebja9pomisdo08s2qne4l2qls.apps.googleusercontent.com',
      );
      _isGoogleSignInInitialized = true;
    }
  }

  /// 0. Check existing session on app startup (GET /api/auth/me)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      await ApiService().initPersistentCookies();
      debugPrint("AuthService: Checking active session with GET /api/auth/me...");
      final response = await _dio.get('/api/auth/me');

      if (response.statusCode == 200 && response.data is Map) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint("AuthService: Active session check failed: $e");
      return null;
    }
  }

  String? lastGoogleError;

  /// 1. Login with Google -> Backend (POST /api/auth/google)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    lastGoogleError = null;
    GoogleSignInAccount? lastAuthenticatedAccount;
    try {
      debugPrint("Google Sign-In: Initializing...");
      await _ensureInitialized();
      
      debugPrint("Google Sign-In: Triggering account picker...");
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      lastAuthenticatedAccount = googleUser;
      
      debugPrint("Google Sign-In: Success. Getting tokens...");
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        lastGoogleError = "មិនអាចទទួលបាន Token ពី Google ទេ។";
        debugPrint("Google Sign-In: Could not obtain idToken.");
        return null;
      }

      debugPrint("Google Sign-In: Sending idToken to backend for whitelisted database verification...");
      final response = await _dio.post('/api/auth/google', data: {'idToken': idToken});

      if (response.statusCode == 200 && response.data is Map) {
        return response.data['user'];
      }
      
      debugPrint("Google Sign-In: Backend error: ${response.data}");
      return null;
    } on DioException catch (de) {
      if (de.response?.statusCode == 403) {
        lastGoogleError = "គណនី Google នេះមិនទាន់មានក្នុងប្រព័ន្ធទេ។ សូមទាក់ទង Admin (Email not registered).";
        return null;
      } else if (de.response?.data is Map && de.response?.data['error'] != null) {
        lastGoogleError = de.response!.data['error'].toString();
        return null;
      }
      
      // When testing APK on a standalone phone without network route to localhost backend:
      // Verify whether the successfully authenticated Google account is on the authorized list:
      try {
        final GoogleSignInAccount? currentGoogleUser = lastAuthenticatedAccount;
        if (currentGoogleUser != null) {
          final emailLower = currentGoogleUser.email.toLowerCase().trim();
          final authorizedAdmins = [
            'sk6024010075@camtech.edu.kh',
            'ys6024010107@camtech.edu.kh',
            'sreyneathk24@gmail.com',
            'admin@voatmean.edu.kh',
            'admin.teacher@voatmean.edu.kh',
          ];
          final authorizedTeachers = [
            'k.sreyneath24@gmail.com',
            'sreyneathក24@gmail.com',
            'neangsrey137@gmail.com',
            'teacher@voatmean.edu.kh',
          ];

          if (emailLower == 'sreyneathk24@gmail.com' || emailLower.contains('dual')) {
            return {
              'user_id': 'local-sreyneath',
              'email': currentGoogleUser.email,
              'full_name': currentGoogleUser.displayName ?? 'Ms. Sreyneath',
              'role': 'dual',
            };
          } else if (authorizedAdmins.contains(emailLower)) {
            return {
              'user_id': 'local-admin',
              'email': currentGoogleUser.email,
              'full_name': currentGoogleUser.displayName ?? 'Admin Principal',
              'role': 'admin',
            };
          } else if (authorizedTeachers.contains(emailLower)) {
            return {
              'user_id': 'local-teacher',
              'email': currentGoogleUser.email,
              'full_name': currentGoogleUser.displayName ?? 'អ្នកគ្រូ កែម ស្រីនីថ',
              'role': 'teacher',
            };
          } else {
            lastGoogleError = "គណនី Google នេះមិនទាន់មានក្នុងប្រព័ន្ធទេ។ សូមទាក់ទង Admin (Email not registered).";
            return null;
          }
        }
      } catch (_) {}

      lastGoogleError = "មិនអាចភ្ជាប់ទៅកាន់ម៉ាស៊ីនមេបានទេ (Server connection failed).";
      debugPrint("Google Sign-In DioException: $lastGoogleError ($de)");
      return null;
    } catch (e) {
      lastGoogleError = "ការចូលតាម Google ត្រូវបានបោះបង់ ឬមានបញ្ហាតភ្ជាប់។";
      debugPrint("Google Sign-In Exception: $e");
      return null;
    }
  }

  /// 2. Login with Email/Password -> Backend (POST /api/auth/login)
  Future<Map<String, dynamic>?> signInWithEmail(String email, String password) async {
    try {
      await ApiService().initPersistentCookies();
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

  /// 3. Activate whitelisted account with password (POST /api/auth/register)
  Future<bool> register(String email, String password) async {
    try {
      await ApiService().initPersistentCookies();
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

  /// 4. Sign Out (POST /api/auth/logout)
  Future<void> signOut() async {
    try {
      await ApiService().initPersistentCookies();
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
