import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../client/client_shipments_service.dart';
import 'shipment_model.dart';
import 'shipment_status_helper.dart';

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
  bool _isCancelling = false;

  Widget _buildRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text('$label: ${value == null || value.isEmpty ? '-' : value}'),
    );
  }

  Future<void> _cancelShipment() async {
    setState(() {
      _isCancelling = true;
    });

    try {
      await _shipmentsService.cancelShipment(widget.shipment.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shipment cancelled successfully'),
        ),
      );

      Navigator.pop(context, true);
    } on DioException catch (e) {
      if (!mounted) return;

      final message =
          e.response?.data?.toString() ?? e.message ?? 'Cancel failed';

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
          _isCancelling = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCancel =
        widget.shipment.id != null && widget.shipment.status != '6';

    final statusName =
        ShipmentStatusHelper.getStatusName(widget.shipment.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildRow('ID', widget.shipment.id?.toString()),
            _buildRow('Status', statusName),
            _buildRow('Recipient name', widget.shipment.recipientName),
            _buildRow('Recipient phone', widget.shipment.recipientPhone),
            _buildRow('Recipient city', widget.shipment.recipientCity),
            _buildRow('Recipient address', widget.shipment.recipientAddress),
            _buildRow(
              'Recipient postal code',
              widget.shipment.recipientPostalCode,
            ),
            _buildRow('Description', widget.shipment.description),
            _buildRow('Created at', widget.shipment.createdAt),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: !canCancel || _isCancelling ? null : _cancelShipment,
                child: _isCancelling
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(canCancel ? 'Cancel shipment' : 'Already cancelled'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}