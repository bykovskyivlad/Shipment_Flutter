import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../shipments/shipment_model.dart';

class CourierShipmentsService {
  final Dio _dio = ApiClient().dio;

  Future<List<ShipmentModel>> getCourierShipments() async {
    final response = await _dio.get('/courier/shipments');

    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(ShipmentModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<ShipmentModel> getShipmentDetails(dynamic shipmentId) async {
    final response = await _dio.get('/courier/shipments/$shipmentId');

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid shipment details response format');
    }

    return ShipmentModel.fromJson(response.data as Map<String, dynamic>);
  }

 Future<ShipmentModel> updateShipmentStatus({
  required dynamic shipmentId,
  required int newStatus,
  String? notes,
}) async {
  final response = await _dio.patch(
    '/courier/shipments/$shipmentId/status',
    data: {
      'newStatus': newStatus,
      'notes': notes,
    },
  );

  if (response.data is! Map<String, dynamic>) {
    throw Exception('Invalid update status response format');
  }

  return ShipmentModel.fromJson(response.data as Map<String, dynamic>);
}
}