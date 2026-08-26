import '../../core/utils/parse.dart';

/// Vente flash active associee a un produit (embarquee dans les cartes/fiches).
class FlashSale {
  const FlashSale({
    required this.promoPrice,
    this.id,
    this.endsAt,
    this.stockInitial,
    this.stockSold,
    this.stockRemaining,
  });

  final int? id;
  final int promoPrice;
  final DateTime? endsAt;
  final int? stockInitial;
  final int? stockSold;
  final int? stockRemaining;

  factory FlashSale.fromJson(Map<String, dynamic> json) => FlashSale(
        id: asIntOrNull(json['id']),
        promoPrice: asInt(json['promo_price']),
        endsAt: asDate(json['ends_at']),
        stockInitial: asIntOrNull(json['stock_initial']),
        stockSold: asIntOrNull(json['stock_sold']),
        stockRemaining: asIntOrNull(json['stock_remaining']),
      );

  static FlashSale? maybe(dynamic json) {
    if (json is Map) return FlashSale.fromJson(asMap(json));
    return null;
  }
}
