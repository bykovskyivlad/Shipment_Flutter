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
}