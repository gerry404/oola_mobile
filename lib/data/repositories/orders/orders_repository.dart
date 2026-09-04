import '../../../domain/models/cart_line.dart';
import '../../../domain/models/delivery_zone.dart';
import '../../../domain/models/order.dart';
import '../../../domain/models/paginated.dart';
import '../../../utils/parse.dart';
import '../../../utils/result.dart';
import '../../../utils/result_helpers.dart';
import '../../services/api/api_client.dart';

/// Resultat de la creation d'une commande.
class OrderCreation {
  const OrderCreation({required this.reference, this.paymentUrl});
  final String reference;
  final String? paymentUrl;
}

/// Zones de livraison et commandes.
class OrdersRepository {
  OrdersRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  Future<Result<List<DeliveryZone>>> deliveryZones() async {
    final res = await _api.get('/delivery-zones');
    return mapResult(res, (v) {
      final list = v is List ? v : asList(asMap(v)['data']);
      return list.map((e) => DeliveryZone.fromJson(asMap(e))).toList();
    });
  }

  Future<Result<OrderCreation>> create({
    required List<CartLine> items,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    required String commune,
    required String paymentMethod,
    String? couponCode,
  }) async {
    final res = await _api.post('/orders', body: {
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
    return mapResult(res, (v) {
      final map = asMap(v);
      return OrderCreation(
        reference: asString(map['reference']),
        paymentUrl: asStringOrNull(map['payment_url']),
      );
    });
  }

  Future<Result<OrderDetail>> order(String reference) async {
    final res = await _api.get('/orders/$reference');
    return mapResult(res, (v) {
      final map = asMap(v);
      return OrderDetail.fromJson(map['data'] is Map ? asMap(map['data']) : map);
    });
  }

  Future<Result<Paginated<OrderSummary>>> myOrders({int page = 1}) async {
    final res = await _api.get('/me/orders', query: {'page': page});
    return mapResult(res, (v) => Paginated.fromJson(asMap(v), OrderSummary.fromJson));
  }
}
