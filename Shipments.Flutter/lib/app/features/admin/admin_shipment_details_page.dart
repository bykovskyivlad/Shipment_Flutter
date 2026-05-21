import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/ui/app_snackbar.dart';
import '../shipments/shipment_model.dart';
import '../shipments/shipment_status_helper.dart';
import 'admin_shipments_service.dart';

class AdminShipmentDetailsPage extends StatefulWidget {
  final dynamic shipmentId;

  const AdminShipmentDetailsPage({
    super.key,
    required this.shipmentId,
  });

  @override
  State<AdminShipmentDetailsPage> createState() =>
      _AdminShipmentDetailsPageState();
}

class _AdminShipmentDetailsPageState extends State<AdminShipmentDetailsPage> {
  final AdminShipmentsService _service = AdminShipmentsService();

  ShipmentModel? _shipment;
  bool _isLoading = true;
  bool _isAssigning = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shipment = await _service.getShipmentDetails(widget.shipmentId);

      if (!mounted) return;

      setState(() {
        _shipment = shipment;
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

  Future<void> _assignCourier() async {
    try {
      final couriers = await _service.getCouriers();

      if (!mounted) return;

      if (couriers.isEmpty) {
        AppSnackbar.showInfo(context, 'No couriers found');
        return;
      }

      dynamic selectedCourierId;

      await showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Text('Assign courier to shipment ${widget.shipmentId}'),
                content: DropdownButtonFormField<dynamic>(
                  initialValue: selectedCourierId,
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
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: selectedCourierId == null
                        ? null
                        : () async {
                            setState(() {
                              _isAssigning = true;
                            });

                            try {
                              await _service.assignCourier(
                                shipmentId: widget.shipmentId,
                                courierId: selectedCourierId,
                              );

                              if (!dialogContext.mounted) return;
                              Navigator.pop(dialogContext);

                              if (!mounted) return;

                              Future.microtask(() {
                                if (!mounted) return;
                                Navigator.pop(context, true);
                              });
                            } on DioException catch (e) {
                              if (!dialogContext.mounted) return;

                              final message =
                                  e.response?.data?.toString() ??
                                      e.message ??
                                      'Assign failed';

                              AppSnackbar.showError(dialogContext, message);
                            } catch (e) {
                              if (!dialogContext.mounted) return;

                              AppSnackbar.showError(
                                dialogContext,
                                'Unexpected error: $e',
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isAssigning = false;
                                });
                              }
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

      AppSnackbar.showError(
        context,
        e.response?.data?.toString() ??
            e.message ??
            'Failed to load couriers',
      );
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.showError(context, 'Unexpected error: $e');
    }
  }

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text('$label: ${value == null || value.isEmpty ? '-' : value}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Shipment Details'),
      ),
      body: Builder(
        builder: (context) {
          if (_isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (_errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final shipment = _shipment;
          if (shipment == null) {
            return const Center(
              child: Text('Shipment not found'),
            );
          }

          final statusName = ShipmentStatusHelper.getStatusName(shipment.status);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildRow('ID', shipment.id?.toString()),
              _buildRow('Status', statusName),
              _buildRow('Recipient name', shipment.recipientName),
              _buildRow('Recipient phone', shipment.recipientPhone),
              _buildRow('Recipient city', shipment.recipientCity),
              _buildRow('Recipient address', shipment.recipientAddress),
              _buildRow('Recipient postal code', shipment.recipientPostalCode),
              _buildRow('Description', shipment.description),
              _buildRow('Created at', shipment.createdAt),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isAssigning ? null : _assignCourier,
                  child: _isAssigning
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Text('Assign / Reassign courier'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}