import 'package:flutter/material.dart';

import '../../core/storage/secure_storage_service.dart';
import '../auth/login_page.dart';
import 'client_shipments_page.dart';
import 'client_create_shipment_page.dart';

class ClientHomePage extends StatelessWidget {
  const ClientHomePage({super.key});

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
        title: const Text('Client Home'),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
body: Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ClientShipmentsPage(),
            ),
          );
        },
          child: const Text('Open my shipments'),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClientCreateShipmentPage(),
              ),
            );
          },
            child: const Text('Create shipment'),
          ),
        ],
        ),
      ),
    );
  }
}