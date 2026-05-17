import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
    data: {
      'email': email,
      'password': password,
    },
  );

  return response.data;
}

  Future<dynamic> register({
    required String email,
    required String password,
    required String username,
    required String role,
  }) async {
    final response = await _dio.post(
      '/auth/register',
    data: {
      'email': email,
      'password': password,
      'username': username,
      'role': role,
    },
  );

  return response.data;
}
}