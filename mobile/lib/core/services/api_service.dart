import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio dio;
  late CookieJar cookieJar;

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    dio = Dio(BaseOptions(
      // 10.0.2.2 is the special alias to your host loopback interface for Android Emulator
      baseUrl: kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      validateStatus: (status) => status! < 500,
    ));

    cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
    
    // Add logging for debugging
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }
}
