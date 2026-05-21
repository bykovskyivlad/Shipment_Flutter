import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../shipments/shipment_model.dart';
import '../shipments/shipment_status_helper.dart';
import 'courier_shipments_service.dart';

class CourierShipmentDetailsPage extends StatefulWidget {
  final dynamic shipmentId;

  const CourierShipmentDetailsPage({
    super.key,
    required this.shipmentId,
  });

  @override
  State<CourierShipmentDetailsPage> createState() =>
      _CourierShipmentDetailsPageState();
}

class _CourierShipmentDetailsPageState
    extends State<CourierShipmentDetailsPage> {
  final CourierShipmentsService _service = CourierShipmentsService();

  ShipmentModel? _shipment;
  bool _isLoading = true;
  bool _isUpdating = false;
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

  Future<void> _changeStatus(int newStatus) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final updated = await _service.updateShipmentStatus(
        shipmentId: widget.shipmentId,
        newStatus: newStatus,
      );

      if (!mounted) return;

      setState(() {
        _shipment = updated;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Shipment status updated to ${ShipmentStatusHelper.getStatusName(updated.status)}',
          ),
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;

      final message =
          e.response?.data?.toString() ?? e.message ?? 'Update failed';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
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

  Widget _buildStatusButtons() {
    final status = int.tryParse(_shipment?.status ?? '');

    if (status == 1) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: _isUpdating ? null : () => _changeStatus(2),
            child: const Text('Picked up'),
          ),
          ElevatedButton(
            onPressed: _isUpdating ? null : () => _changeStatus(6),
            child: const Text('Cancel shipment'),
          ),
        ],
      );
    }

    if (status == 2) {
      return ElevatedButton(
        onPressed: _isUpdating ? null : () => _changeStatus(3),
        child: const Text('Out for delivery'),
      );
    }

    if (status == 3) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            onPressed: _isUpdating ? null : () => _changeStatus(4),
            child: const Text('Delivered'),
          ),
          ElevatedButton(
            onPressed: _isUpdating ? null : () => _changeStatus(5),
            child: const Text('Delivery failed'),
          ),
        ],
      );
    }

    return const Text('No further status changes available');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courier Shipment Details'),
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
              const Text(
                'Change status',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatusButtons(),
            ],
          );
        },
      ),
    );
  }
}