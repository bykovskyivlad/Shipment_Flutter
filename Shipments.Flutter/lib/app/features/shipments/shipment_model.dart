class ShipmentModel {
  final dynamic id;
  final String? status;
  final String? recipientName;
  final String? recipientPhone;
  final String? recipientCity;
  final String? recipientAddress;
  final String? recipientPostalCode;
  final String? description;
  final String? createdAt;

  ShipmentModel({
    required this.id,
    required this.status,
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientCity,
    required this.recipientAddress,
    required this.recipientPostalCode,
    required this.description,
    required this.createdAt,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    String? description = json['description']?.toString();

    final events = json['events'];
    if ((description == null || description.isEmpty) && events is List) {
      for (final event in events) {
        if (event is Map<String, dynamic>) {
          final notes = event['notes']?.toString();
          if (notes != null && notes.trim().isNotEmpty) {
            description = notes;
            break;
          }
        }
      }
    }

    return ShipmentModel(
      id: json['id'],
      status: json['status']?.toString(),
      recipientName: json['recipientName']?.toString(),
      recipientPhone: json['recipientPhone']?.toString(),
      recipientCity: json['recipientCity']?.toString(),
      recipientAddress: json['recipientAddress']?.toString(),
      recipientPostalCode: json['recipientPostalCode']?.toString(),
      description: description,
      createdAt: json['createdAt']?.toString(),
    );
  }
}