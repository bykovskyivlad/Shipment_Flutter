import 'package:flutter/material.dart';

class CourierHomePage extends StatelessWidget {
  const CourierHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courier Home'),
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