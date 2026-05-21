import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../shipments/shipment_card.dart';
import '../shipments/shipment_model.dart';
import 'admin_shipments_service.dart';

class AdminShipmentsPage extends StatefulWidget {
  const AdminShipmentsPage({super.key});

  @override
  State<AdminShipmentsPage> createState() => _AdminShipmentsPageState();
}

class _AdminShipmentsPageState extends State<AdminShipmentsPage> {
  final AdminShipmentsService _shipmentsService = AdminShipmentsService();

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
      final shipments = await _shipmentsService.getAllShipments();

      if (!mounted) return;

      setState(() {
        _shipments = shipments;
      });
    } on DioException catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.response?.data?.toString() ?? e.message ?? 'Request failed';
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

  Future<void> _showAssignCourierDialog(ShipmentModel shipment) async {
    try {
      final couriers = await _shipmentsService.getCouriers();

      if (!mounted) return;

      if (couriers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No couriers found'),
          ),
        );
        return;
      }

      dynamic selectedCourierId;

      await showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Assign courier to shipment ${shipment.id}'),
                content: DropdownButtonFormField<dynamic>(
                  value: selectedCourierId,
                  items: couriers.map((courier) {
                    final id = courier['id'];
                    final name = courier['userName'] ??
                        courier['username'] ??
                        courier['email'] ??
                        courier['name'] ??
                        'Courier';

                    return DropdownMenuItem<dynamic>(
                      value: id,
                      child: Text(name.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCourierId = value;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Courier',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: selectedCourierId == null
                        ? null
                        : () async {
                            try {
                              await _shipmentsService.assignCourier(
                                shipmentId: shipment.id,
                                courierId: selectedCourierId,
                              );

                              if (!context.mounted) return;

                              Navigator.pop(context);

                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Courier assigned successfully'),
                                ),
                              );

                              _loadShipments();
                            } on DioException catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    e.response?.data?.toString() ??
                                        e.message ??
                                        'Assign failed',
                                  ),
                                ),
                              );
                            } catch (e) {
                              if (!context.mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Unexpected error: $e'),
                                ),
                              );
                            }
                          },
                    child: const Text('Assign'),
                  ),
                ],
              );
            },
          );
        },
      );
    } on DioException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.response?.data?.toString() ?? e.message ?? 'Failed to load couriers',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Shipments'),
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

                return Card(
                  child: ListTile(
                    title: Text(
                      'Shipment ${shipment.id ?? '-'} • ${shipment.status ?? '-'}',
                    ),
                    subtitle: Text(
                      shipment.recipientName ??
                          shipment.recipientCity ??
                          'No details',
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _showAssignCourierDialog(shipment),
                      child: const Text('Assign'),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}