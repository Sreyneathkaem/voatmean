import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;
  late CookieJar cookieJar;
  bool _isPersistentJarInitialized = false;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(BaseOptions(
      // 10.0.2.2 is the loopback alias for Android Emulator to access localhost backend
      baseUrl: kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000',
      connectTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 3),
      validateStatus: (status) => status != null && status < 500,
    ));

    // Load any custom configured baseUrl from SharedPreferences
    _loadCustomBaseUrl();

    // Initialize with standard in-memory jar initially
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    
    // Logging for debugging requests/responses
    dio.interceptors.add(LogInterceptor(
      requestBody: false,
      responseBody: false,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  Future<void> _loadCustomBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString('custom_base_url');
      if (savedUrl != null && savedUrl.trim().isNotEmpty) {
        dio.options.baseUrl = savedUrl.trim();
        debugPrint("ApiService: Loaded custom baseUrl: ${dio.options.baseUrl}");
      }
    } catch (_) {}
  }

  Future<void> setBaseUrl(String newUrl) async {
    final clean = newUrl.trim();
    if (clean.isNotEmpty) {
      dio.options.baseUrl = clean;
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('custom_base_url', clean);
      } catch (_) {}
      debugPrint("ApiService: Updated baseUrl to $clean");
    }
  }

  /// Initializes persistent disk storage for HttpOnly session cookies across app restarts
  Future<void> initPersistentCookies() async {
    if (_isPersistentJarInitialized) return;

    if (!kIsWeb) {
      try {
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String appDocPath = "${appDocDir.path}/.cookies/";
        final persistJar = PersistCookieJar(storage: FileStorage(appDocPath));

        // Replace temporary in-memory CookieManager with PersistCookieJar
        dio.interceptors.removeWhere((element) => element is CookieManager);
        cookieJar = persistJar;
        dio.interceptors.add(CookieManager(persistJar));
        _isPersistentJarInitialized = true;
        debugPrint("ApiService: Persistent cookie storage initialized at $appDocPath");
      } catch (e) {
        debugPrint("ApiService: Failed to initialize persistent cookie storage: $e");
      }
    }
  }
}
