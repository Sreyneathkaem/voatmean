import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

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
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) => status != null && status < 500,
    ));

    // Initialize with standard in-memory jar initially
    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    
    // Logging for debugging requests/responses
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
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
