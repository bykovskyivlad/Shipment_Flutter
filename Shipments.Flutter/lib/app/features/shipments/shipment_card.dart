import 'package:flutter/material.dart';
import 'shipment_model.dart';

class ShipmentCard extends StatelessWidget {
  final ShipmentModel shipment;
  final VoidCallback? onTap;

  const ShipmentCard({
    super.key,
    required this.shipment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        'Shipment ${shipment.id ?? '-'}${shipment.status != null ? ' • ${shipment.status}' : ''}';

    final subtitle = [
      shipment.recipientName,
      shipment.recipientCity,
    ].where((e) => e != null && e.isNotEmpty).join(' • ');

    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle.isEmpty ? 'No details' : subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}