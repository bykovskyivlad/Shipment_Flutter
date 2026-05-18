import 'package:flutter/material.dart';

import '../../core/storage/secure_storage_service.dart';
import '../auth/login_page.dart';

class CourierHomePage extends StatelessWidget {
  const CourierHomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final storageService = SecureStorageService();
    await storageService.deleteToken();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courier Home'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Courier dashboard',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}