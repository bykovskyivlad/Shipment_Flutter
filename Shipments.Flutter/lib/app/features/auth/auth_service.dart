import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import 'login_response.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<LoginResponse> login({
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

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid login response format');
    }

    return LoginResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> register({
    required String email,
    required String password,
    required String role,
  }) async {
    await _dio.post(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'role': role,
      },
    );
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    await _dio.post(
      '/auth/change-password',
      data: {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      },
    );
  }
}