import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';

/// Acces livreur : file des livraisons, prise en charge, confirmation.
class DeliveryRepository {
  DeliveryRepository(this._dio);
  final Dio _dio;

  /// File des commandes a livrer (payees / COD confirmees).
  Future<Paginated<OrderSummary>> queue({int page = 1}) async {
    try {
      final res = await _dio.get('/delivery/queue', queryParameters: {'page': page});
      return Paginated.fromJson(
        Map<String, dynamic>.from(res.data as Map),
        OrderSummary.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Le livreur reserve une commande.
  Future<void> take(int orderId) async {
    try {
      await _dio.post('/delivery/orders/$orderId/take');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Confirme la remise via le code OTP donne par le client.
  Future<void> confirm(int orderId, String otp) async {
    try {
      await _dio.post('/delivery/orders/$orderId/confirm', data: {'otp': otp});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
