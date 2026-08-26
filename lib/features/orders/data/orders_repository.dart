import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/delivery_zone.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import '../../cart/domain/cart_line.dart';

/// Resultat de la creation d'une commande.
class OrderCreation {
  const OrderCreation({required this.reference, this.paymentUrl});
  final String reference;

  /// URL de paiement (Mobile Money / carte). Null en paiement a la livraison.
  final String? paymentUrl;
}

/// Acces aux zones de livraison et aux commandes.
class OrdersRepository {
  OrdersRepository(this._dio);
  final Dio _dio;

  /// Zones de livraison actives (tarifs par commune).
  Future<List<DeliveryZone>> deliveryZones() async {
    try {
      final res = await _dio.get('/delivery-zones');
      final list = res.data is List ? res.data : (res.data['data'] ?? []);
      return (list as List)
          .map((e) => DeliveryZone.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Cree une commande a partir des lignes du panier.
  Future<OrderCreation> create({
    required List<CartLine> items,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String commune,
    required String paymentMethod, // mobile_money | cash_on_delivery
    String? couponCode,
  }) async {
    try {
      final res = await _dio.post('/orders', data: {
        'items': items
            .map((l) => {
                  'product_slug': l.slug,
                  if (l.variantId != null) 'variant_id': l.variantId,
                  'quantity': l.quantity,
                })
            .toList(),
        'customer_name': customerName,
        'customer_phone': customerPhone,
        if (customerEmail != null && customerEmail.isNotEmpty)
          'customer_email': customerEmail,
        'commune': commune,
        'payment_method': paymentMethod,
        if (couponCode != null && couponCode.isNotEmpty) 'coupon_code': couponCode,
      });
      final data = Map<String, dynamic>.from(res.data as Map);
      return OrderCreation(
        reference: data['reference'].toString(),
        paymentUrl: data['payment_url']?.toString(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Detail + suivi d'une commande par reference.
  Future<OrderDetail> order(String reference) async {
    try {
      final res = await _dio.get('/orders/$reference');
      final data = Map<String, dynamic>.from(
          (res.data['data'] ?? res.data) as Map);
      return OrderDetail.fromJson(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Historique des commandes du client connecte.
  Future<Paginated<OrderSummary>> myOrders({int page = 1}) async {
    try {
      final res = await _dio.get('/me/orders', queryParameters: {'page': page});
      return Paginated.fromJson(
        Map<String, dynamic>.from(res.data as Map),
        OrderSummary.fromJson,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
