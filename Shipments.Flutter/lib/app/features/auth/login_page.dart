import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/ui/app_snackbar.dart';
import 'app_roles.dart';
import '../../core/auth/jwt_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../admin/admin_home_page.dart';
import '../client/client_home_page.dart';
import '../courier/courier_home_page.dart';
import 'auth_service.dart';
import 'change_password_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final SecureStorageService _storageService = SecureStorageService();
  final JwtService _jwtService = JwtService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _storageService.saveToken(result.token);

      final role = _jwtService.getRoleFromToken(result.token);

      if (!mounted) return;

      if (result.mustChangePassword) {
        final changed = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ChangePasswordPage(),
          ),
        );

        await _storageService.deleteToken();

        if (!mounted) return;

        if (changed == true) {
          AppSnackbar.showSuccess(
            context,
            'Password changed. Please login again.',
          );
        }

        return;
      }

      Widget destination;

      switch (role) {
        case AppRoles.admin:
          destination = const AdminHomePage();
          break;
        case AppRoles.courier:
          destination = const CourierHomePage();
          break;
        case AppRoles.client:
          destination = const ClientHomePage();
          break;
        default:
          destination = const ClientHomePage();
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => destination,
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      final message =
          e.response?.data?.toString() ?? e.message ?? 'Login failed';

      AppSnackbar.showError(context, message);
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.showError(context, 'Unexpected error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Shipments System',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitLogin,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: const Text('Don’t have an account? Register'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}