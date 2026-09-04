import '../../utils/parse.dart';

/// Tableau de bord vendeur.
class VendorDashboard {
  const VendorDashboard({
    required this.shopName,
    this.logoUrl,
    this.kycValidated = false,
    this.isCertified = false,
    this.ordersPreparing = 0,
    this.ordersDelivering = 0,
    this.ordersDelivered = 0,
    this.revenueToday = 0,
    this.revenueWeek = 0,
    this.revenueMonth = 0,
    this.productsApproved = 0,
    this.productsPending = 0,
    this.productsDraft = 0,
    this.availableBalance = 0,
  });

  final String shopName;
  final String? logoUrl;
  final bool kycValidated;
  final bool isCertified;
  final int ordersPreparing;
  final int ordersDelivering;
  final int ordersDelivered;
  final int revenueToday;
  final int revenueWeek;
  final int revenueMonth;
  final int productsApproved;
  final int productsPending;
  final int productsDraft;
  final int availableBalance;

  factory VendorDashboard.fromJson(Map<String, dynamic> json) {
    final shop = asMap(json['shop']);
    final orders = asMap(json['orders']);
    final revenue = asMap(json['revenue']);
    final products = asMap(json['products']);
    final wallet = asMap(json['wallet']);
    return VendorDashboard(
      shopName: asString(shop['name'], 'Ma boutique'),
      logoUrl: asStringOrNull(shop['logo_url']),
      kycValidated: asBool(shop['kyc_validated']),
      isCertified: asBool(shop['is_certified']),
      ordersPreparing: asInt(orders['preparing']),
      ordersDelivering: asInt(orders['delivering']),
      ordersDelivered: asInt(orders['delivered']),
      revenueToday: asInt(revenue['today']),
      revenueWeek: asInt(revenue['week']),
      revenueMonth: asInt(revenue['month']),
      productsApproved: asInt(products['approved']),
      productsPending: asInt(products['pending']),
      productsDraft: asInt(products['draft']),
      availableBalance: asInt(wallet['available_balance']),
    );
  }
}

/// Produit du catalogue vendeur.
class VendorProduct {
  const VendorProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.stock,
    required this.status,
    this.rejectionReason,
    this.posterUrl,
    this.hasVideo = false,
  });

  final int id;
  final String title;
  final int price;
  final int stock;
  final String status;
  final String? rejectionReason;
  final String? posterUrl;
  final bool hasVideo;

  String get statusLabel => switch (status) {
        'approved' => 'En ligne',
        'pending' => 'En validation',
        'rejected' => 'Refuse',
        'draft' => 'Brouillon',
        'paused' => 'En pause',
        _ => status,
      };

  factory VendorProduct.fromJson(Map<String, dynamic> json) {
    final video = json['video'];
    return VendorProduct(
      id: asInt(json['id']),
      title: asString(json['title']),
      price: asInt(json['price']),
      stock: asInt(json['stock']),
      status: asString(json['status']),
      rejectionReason: asStringOrNull(json['rejection_reason']),
      posterUrl: video is Map ? asStringOrNull(video['poster_url']) : null,
      hasVideo: video is Map && asStringOrNull(video['video_url']) != null,
    );
  }
}

/// Mouvement de portefeuille.
class WalletTransaction {
  const WalletTransaction({
    required this.type,
    required this.amount,
    this.description,
    this.createdAt,
  });

  final String type;
  final int amount;
  final String? description;
  final DateTime? createdAt;

  bool get isCredit => type == 'credit' || type == 'release';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        type: asString(json['type']),
        amount: asInt(json['amount']),
        description: asStringOrNull(json['description']),
        createdAt: asDate(json['created_at']),
      );
}

/// Portefeuille vendeur.
class VendorWallet {
  const VendorWallet({
    required this.availableBalance,
    this.pendingBalance = 0,
    this.transactions = const [],
  });

  final int availableBalance;
  final int pendingBalance;
  final List<WalletTransaction> transactions;

  factory VendorWallet.fromJson(Map<String, dynamic> json) {
    final wallet = asMap(json['wallet']);
    return VendorWallet(
      availableBalance: asInt(wallet['available_balance']),
      pendingBalance: asInt(wallet['pending_balance']),
      transactions: asList(json['transactions'])
          .map((e) => WalletTransaction.fromJson(asMap(e)))
          .toList(),
    );
  }
}
