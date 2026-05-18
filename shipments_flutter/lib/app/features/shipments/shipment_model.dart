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
    return ShipmentModel(
      id: json['id'],
      status: json['status']?.toString(),
      recipientName: json['recipientName']?.toString(),
      recipientPhone: json['recipientPhone']?.toString(),
      recipientCity: json['recipientCity']?.toString(),
      recipientAddress: json['recipientAddress']?.toString(),
      recipientPostalCode: json['recipientPostalCode']?.toString(),
      description: json['description']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}