import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/ui/app_snackbar.dart';
import 'client_shipments_service.dart';

class ClientCreateShipmentPage extends StatefulWidget {
  const ClientCreateShipmentPage({super.key});

  @override
  State<ClientCreateShipmentPage> createState() =>
      _ClientCreateShipmentPageState();
}

class _ClientCreateShipmentPageState extends State<ClientCreateShipmentPage> {
  final _formKey = GlobalKey<FormState>();

  final _recipientNameController = TextEditingController();
  final _recipientPhoneController = TextEditingController();
  final _recipientCityController = TextEditingController();
  final _recipientAddressController = TextEditingController();
  final _recipientPostalCodeController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();

  final ClientShipmentsService _shipmentsService = ClientShipmentsService();

  bool _isLoading = false;

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _recipientCityController.dispose();
    _recipientAddressController.dispose();
    _recipientPostalCodeController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _shipmentsService.createShipment(
        recipientName: _recipientNameController.text.trim(),
        recipientPhone: _recipientPhoneController.text.trim(),
        recipientCity: _recipientCityController.text.trim(),
        recipientAddress: _recipientAddressController.text.trim(),
        recipientPostalCode: _recipientPostalCodeController.text.trim(),
        weight: double.parse(_weightController.text.trim()),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      AppSnackbar.showSuccess(context, 'Shipment created successfully');
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;

      final message =
          e.response?.data?.toString() ?? e.message ?? 'Create shipment failed';

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
        title: const Text('Create Shipment'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _recipientNameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter recipient name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _recipientPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter recipient phone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _recipientCityController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient city',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter recipient city';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _recipientAddressController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter recipient address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _recipientPostalCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Recipient postal code',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.markunread_mailbox_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter recipient postal code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Weight',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter weight';
                        }

                        final parsed = double.tryParse(value.trim());
                        if (parsed == null || parsed <= 0) {
                          return 'Enter valid weight';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.description_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Text('Create shipment'),
                      ),
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