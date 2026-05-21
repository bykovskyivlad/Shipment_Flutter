class ShipmentStatusHelper {
  static String getStatusName(String? status) {
    switch (status) {
      case '1':
        return 'Created';
      case '2':
        return 'Picked Up';
      case '3':
        return 'Out for Delivery';
      case '4':
        return 'Delivered';
      case '5':
        return 'Delivery Failed';
      case '6':
        return 'Canceled';
      default:
        return 'Unknown';
    }
  }
}