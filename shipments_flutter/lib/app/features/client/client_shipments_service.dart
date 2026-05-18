import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../shipments/shipment_model.dart';

class ClientShipmentsService {
  final Dio _dio = ApiClient().dio;

  Future<List<ShipmentModel>> getMyShipments() async {
    final response = await _dio.get('/shipments/mine');

    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(ShipmentModel.fromJson)
          .toList();
    }

    return [];
  }
Future<void> cancelShipment(dynamic shipmentId) async {
  await _dio.patch(
    '/shipments/$shipmentId/cancel',
    data: {},
  );
}
Future<dynamic> createShipment({
  required String recipientName,
  required String recipientPhone,
  required String recipientCity,
  required String recipientAddress,
  required String recipientPostalCode,
  required double weight,
  required String description,
}) async {
  final response = await _dio.post(
    '/shipments',
    data: {
      'recipientName': recipientName,
      'recipientPhone': recipientPhone,
      'recipientCity': recipientCity,
      'recipientAddress': recipientAddress,
      'recipientPostalCode': recipientPostalCode,
      'weight': weight,
      'description': description,
    },
  );
 
  return response.data;
}
}