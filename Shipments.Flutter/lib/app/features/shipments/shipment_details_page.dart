import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../client/client_shipments_service.dart';
import '../../core/ui/app_snackbar.dart';
import 'shipment_model.dart';
import 'shipment_status_helper.dart';
import 'shipment_statuses.dart';

class ShipmentDetailsPage extends StatefulWidget {
  final ShipmentModel shipment;

  const ShipmentDetailsPage({
    super.key,
    required this.shipment,
  });

  @override
  State<ShipmentDetailsPage> createState() => _ShipmentDetailsPageState();
}

class _ShipmentDetailsPageState extends State<ShipmentDetailsPage> {
  final ClientShipmentsService _shipmentsService = ClientShipmentsService();

  ShipmentModel? _shipment;
  bool _isLoading = true;
  bool _isCancelling = false;
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
      final shipment = await _shipmentsService.getShipmentDetails(
        widget.shipment.id,
      );

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

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text('$label: ${value == null || value.isEmpty ? '-' : value}'),
    );
  }

  Future<void> _cancelShipment() async {
    final shipment = _shipment;
    if (shipment == null) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await _shipmentsService.cancelShipment(shipment.id);

      if (!mounted) return;

      AppSnackbar.showSuccess(context, 'Shipment cancelled successfully');
      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;

      final message =
          e.response?.data?.toString() ?? e.message ?? 'Cancel failed';

      AppSnackbar.showError(context, message);
    } catch (e) {
      if (!mounted) return;

      AppSnackbar.showError(context, 'Unexpected error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
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

          final canCancel = shipment.id != null &&
              shipment.status != ShipmentStatuses.canceled;

          final statusName =
              ShipmentStatusHelper.getStatusName(shipment.status);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
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
                    onPressed:
                        !canCancel || _isCancelling ? null : _cancelShipment,
                    child: _isCancelling
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            canCancel
                                ? 'Cancel shipment'
                                : 'Already cancelled',
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}