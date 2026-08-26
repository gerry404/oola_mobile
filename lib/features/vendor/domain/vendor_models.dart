import '../../../core/utils/parse.dart';

/// Tableau de bord vendeur.
class VendorDashboard {
  const VendorDashboard({
    required this.shopName,
    required this.shopStatus,
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
    this.productsRejected = 0,
    this.productsDraft = 0,
    this.availableBalance = 0,
    this.pendingBalance = 0,
  });

  final String shopName;
  final String shopStatus;
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
  final int productsRejected;
  final int productsDraft;
  final int availableBalance;
  final int pendingBalance;

  factory VendorDashboard.fromJson(Map<String, dynamic> json) {
    final shop = asMap(json['shop']);
    final orders = asMap(json['orders']);
    final revenue = asMap(json['revenue']);
    final products = asMap(json['products']);
    final wallet = asMap(json['wallet']);
    return VendorDashboard(
      shopName: asString(shop['name'], 'Ma boutique'),
      shopStatus: asString(shop['status']),
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
      productsRejected: asInt(products['rejected']),
      productsDraft: asInt(products['draft']),
      availableBalance: asInt(wallet['available_balance']),
      pendingBalance: asInt(wallet['pending_balance']),
    );
  }
}

/// Produit du vendeur (catalogue).
class VendorProduct {
  const VendorProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.stock,
    required this.status,
    this.posterUrl,
    this.hasVideo = false,
  });

  final int id;
  final String title;
  final int price;
  final int stock;
  final String status; // draft | pending | approved | rejected | paused
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
    String? poster;
    bool hasVid = false;
    if (video is Map) {
      poster = asStringOrNull(video['poster_url']);
      hasVid = asStringOrNull(video['video_url']) != null;
    }
    return VendorProduct(
      id: asInt(json['id']),
      title: asString(json['title']),
      price: asInt(json['price']),
      stock: asInt(json['stock']),
      status: asString(json['status']),
      posterUrl: poster,
      hasVideo: hasVid,
    );
  }
}

/// Portefeuille vendeur + transactions.
class VendorWallet {
  const VendorWallet({
    required this.availableBalance,
    required this.pendingBalance,
    this.totalEarned = 0,
    this.commissionRate = 0,
    this.kycValidated = false,
    this.transactions = const [],
  });

  final int availableBalance;
  final int pendingBalance;
  final int totalEarned;
  final double commissionRate;
  final bool kycValidated;
  final List<WalletTransaction> transactions;

  factory VendorWallet.fromJson(Map<String, dynamic> json) {
    final wallet = asMap(json['wallet']);
    return VendorWallet(
      availableBalance: asInt(wallet['available_balance']),
      pendingBalance: asInt(wallet['pending_balance']),
      totalEarned: asInt(wallet['total_earned']),
      commissionRate: asDouble(json['commission_rate']),
      kycValidated: asBool(json['kyc_validated']),
      transactions: asList(json['transactions'])
          .map((e) => WalletTransaction.fromJson(asMap(e)))
          .toList(),
    );
  }
}

/// Mouvement du portefeuille.
class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    this.description,
    this.createdAt,
  });

  final int id;
  final String type; // credit | debit | hold | release | withdrawal
  final int amount;
  final String? description;
  final DateTime? createdAt;

  bool get isCredit => type == 'credit' || type == 'release';

  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: asInt(json['id']),
        type: asString(json['type']),
        amount: asInt(json['amount']),
        description: asStringOrNull(json['description']),
        createdAt: asDate(json['created_at']),
      );
}
