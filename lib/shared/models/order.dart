import '../../core/utils/parse.dart';

/// Ligne d'une commande.
class OrderItem {
  const OrderItem({
    required this.title,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
    this.variant,
  });

  final String title;
  final String? variant;
  final int quantity;
  final int unitPrice;
  final int lineTotal;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        title: asString(json['title'], asString(json['product_title'])),
        variant: asStringOrNull(json['variant'] ?? json['variant_label']),
        quantity: asInt(json['quantity']),
        unitPrice: asInt(json['unit_price']),
        lineTotal: asInt(json['line_total']),
      );
}

/// Etape de la timeline de suivi.
class OrderStep {
  const OrderStep({
    required this.key,
    required this.label,
    required this.state,
    this.reachedAt,
    this.terminal = false,
  });

  final String key;
  final String label;
  final String state; // done | current | upcoming
  final DateTime? reachedAt;
  final bool terminal;

  bool get isDone => state == 'done';
  bool get isCurrent => state == 'current';

  factory OrderStep.fromJson(Map<String, dynamic> json) => OrderStep(
        key: asString(json['key']),
        label: asString(json['label']),
        state: asString(json['state'], 'upcoming'),
        reachedAt: asDate(json['reached_at']),
        terminal: asBool(json['terminal']),
      );
}

/// Statuts de commande (alignes sur le backend).
enum OrderStatus {
  pending,
  confirmed,
  paid,
  readyForPickup,
  assigned,
  outForDelivery,
  delivered,
  cancelled,
  refunded,
  disputed,
  unknown;

  static OrderStatus parse(String? v) => switch (v) {
        'pending' => pending,
        'confirmed' => confirmed,
        'paid' => paid,
        'ready_for_pickup' => readyForPickup,
        'assigned' => assigned,
        'out_for_delivery' => outForDelivery,
        'delivered' => delivered,
        'cancelled' => cancelled,
        'refunded' => refunded,
        'disputed' => disputed,
        _ => unknown,
      };

  String get label => switch (this) {
        pending => 'En attente',
        confirmed => 'Confirmee',
        paid => 'Payee',
        readyForPickup => 'Prete',
        assigned => 'Attribuee',
        outForDelivery => 'En livraison',
        delivered => 'Livree',
        cancelled => 'Annulee',
        refunded => 'Remboursee',
        disputed => 'En litige',
        unknown => 'Commande',
      };
}

/// Resume de commande (historique client / vendeur / file livreur).
class OrderSummary {
  const OrderSummary({
    required this.reference,
    required this.status,
    required this.total,
    this.commune,
    this.paymentStatus,
    this.customerName,
    this.customerPhone,
    this.totalForShop,
    this.createdAt,
    this.paidAt,
    this.receiptUrl,
    this.items = const [],
  });

  final String reference;
  final OrderStatus status;
  final int total;
  final String? commune;
  final String? paymentStatus;
  final String? customerName;
  final String? customerPhone;
  final int? totalForShop;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final String? receiptUrl;
  final List<OrderItem> items;

  factory OrderSummary.fromJson(Map<String, dynamic> json) => OrderSummary(
        reference: asString(json['reference']),
        status: OrderStatus.parse(asStringOrNull(json['status'])),
        total: asInt(json['total']),
        commune: asStringOrNull(json['commune']),
        paymentStatus: asStringOrNull(json['payment_status']),
        customerName: asStringOrNull(json['customer_name']),
        customerPhone: asStringOrNull(json['customer_phone']),
        totalForShop: asIntOrNull(json['total_for_shop']),
        createdAt: asDate(json['created_at']),
        paidAt: asDate(json['paid_at']),
        receiptUrl: asStringOrNull(json['receipt_url']),
        items: asList(json['items']).map((e) => OrderItem.fromJson(asMap(e))).toList(),
      );
}

/// Detail complet d'une commande + suivi.
class OrderDetail {
  const OrderDetail({
    required this.reference,
    required this.status,
    required this.total,
    required this.subtotal,
    required this.deliveryFee,
    this.couponCode,
    this.couponDiscount = 0,
    this.commune,
    this.customerName,
    this.customerPhone,
    this.deliveryCode,
    this.paymentMethod,
    this.paymentStatus,
    this.createdAt,
    this.paidAt,
    this.receiptUrl,
    this.deliveryUserName,
    this.deliveryUserPhone,
    this.timeline = const [],
    this.items = const [],
  });

  final String reference;
  final OrderStatus status;
  final int total;
  final int subtotal;
  final int deliveryFee;
  final String? couponCode;
  final int couponDiscount;
  final String? commune;
  final String? customerName;
  final String? customerPhone;
  final String? deliveryCode;
  final String? paymentMethod;
  final String? paymentStatus;
  final DateTime? createdAt;
  final DateTime? paidAt;
  final String? receiptUrl;
  final String? deliveryUserName;
  final String? deliveryUserPhone;
  final List<OrderStep> timeline;
  final List<OrderItem> items;

  bool get isPaid => paymentStatus == 'paid';

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    final du = json['delivery_user'] is Map ? asMap(json['delivery_user']) : null;
    return OrderDetail(
      reference: asString(json['reference']),
      status: OrderStatus.parse(asStringOrNull(json['status'])),
      total: asInt(json['total']),
      subtotal: asInt(json['subtotal']),
      deliveryFee: asInt(json['delivery_fee']),
      couponCode: asStringOrNull(json['coupon_code']),
      couponDiscount: asInt(json['coupon_discount']),
      commune: asStringOrNull(json['commune']),
      customerName: asStringOrNull(json['customer_name']),
      customerPhone: asStringOrNull(json['customer_phone']),
      deliveryCode: asStringOrNull(json['delivery_code']),
      paymentMethod: asStringOrNull(json['payment_method']),
      paymentStatus: asStringOrNull(json['payment_status']),
      createdAt: asDate(json['created_at']),
      paidAt: asDate(json['paid_at']),
      receiptUrl: asStringOrNull(json['receipt_url']),
      deliveryUserName: du != null ? asStringOrNull(du['name']) : null,
      deliveryUserPhone: du != null ? asStringOrNull(du['phone']) : null,
      timeline: asList(json['timeline']).map((e) => OrderStep.fromJson(asMap(e))).toList(),
      items: asList(json['items']).map((e) => OrderItem.fromJson(asMap(e))).toList(),
    );
  }
}
