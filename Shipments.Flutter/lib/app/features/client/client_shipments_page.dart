import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../shipments/shipment_card.dart';
import '../shipments/shipment_details_page.dart';
import '../shipments/shipment_model.dart';
import 'client_shipments_service.dart';

class ClientShipmentsPage extends StatefulWidget {
  const ClientShipmentsPage({super.key});

  @override
  State<ClientShipmentsPage> createState() => _ClientShipmentsPageState();
}

class _ClientShipmentsPageState extends State<ClientShipmentsPage> {
  final ClientShipmentsService _shipmentsService = ClientShipmentsService();

  bool _isLoading = true;
  String? _errorMessage;
  List<ShipmentModel> _shipments = [];

  @override
  void initState() {
    super.initState();
    _loadShipments();
  }

 Future<void> _loadShipments() async {
  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final shipments = await _shipmentsService.getMyShipments();

    if (!mounted) return;

    setState(() {
      _shipments = shipments;
    });
} on DioException catch (e) {
  if (!mounted) return;

  setState(() {
    _errorMessage =
        e.response?.data?.toString() ??
        e.message ??
        'Request failed';
  });
} catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = 'Unexpected error: $e';
    });
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
        title: const Text('My Shipments'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadShipments,
        child: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (_errorMessage != null) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              );
            }

            if (_shipments.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text('No shipments found'),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _shipments.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final shipment = _shipments[index];
                return ShipmentCard(
                  shipment: shipment,
                  onTap: () async {
                        final result = await Navigator.push(
                          context,
                        MaterialPageRoute(
                          builder: (context) => ShipmentDetailsPage(
                          shipment: shipment,
                        ),
                      ),
                    );

                    if (result == true) {
                       _loadShipments();
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}