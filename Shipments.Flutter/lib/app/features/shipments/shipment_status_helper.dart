import 'shipment_statuses.dart';

class ShipmentStatusHelper {
  static String getStatusName(String? status) {
    switch (status) {
      case ShipmentStatuses.created:
        return 'Created';
      case ShipmentStatuses.pickedUp:
        return 'Picked Up';
      case ShipmentStatuses.outForDelivery:
        return 'Out for Delivery';
      case ShipmentStatuses.delivered:
        return 'Delivered';
      case ShipmentStatuses.deliveryFailed:
        return 'Delivery Failed';
      case ShipmentStatuses.canceled:
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }
}