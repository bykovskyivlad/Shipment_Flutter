import 'package:dio/dio.dart';

import '../../core/api/api_client.dart';
import '../shipments/shipment_model.dart';

class AdminShipmentsService {
  final Dio _dio = ApiClient().dio;

  Future<List<ShipmentModel>> getAllShipments() async {
    final response = await _dio.get('/admin/shipments');

    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .map(ShipmentModel.fromJson)
          .toList();
    }

    return [];
  }

  Future<ShipmentModel> getShipmentDetails(dynamic shipmentId) async {
    final response = await _dio.get('/admin/shipments/$shipmentId');

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Invalid shipment details response format');
    }

    return ShipmentModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> getCouriers() async {
    final response = await _dio.get('/admin/shipments/couriers');

    if (response.data is List) {
      return (response.data as List)
          .whereType<Map<String, dynamic>>()
          .toList();
    }

    return [];
  }

  Future<void> assignCourier({
    required dynamic shipmentId,
    required dynamic courierId,
  }) async {
    await _dio.patch('/admin/shipments/$shipmentId/assign/$courierId');
  }
}