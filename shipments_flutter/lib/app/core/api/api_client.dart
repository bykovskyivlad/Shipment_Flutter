import 'package:dio/dio.dart';
import 'auth_interceptor.dart';

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:5014/api';

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.add(AuthInterceptor());
}