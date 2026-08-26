import '../../../core/utils/parse.dart';

/// Ligne de panier persistee localement.
class CartLine {
  const CartLine({
    required this.slug,
    required this.title,
    required this.price,
    this.quantity = 1,
    this.posterUrl,
    this.shopName,
    this.variantId,
    this.variantLabel,
  });

  final String slug;
  final String title;
  final int price;
  final int quantity;
  final String? posterUrl;
  final String? shopName;
  final int? variantId;
  final String? variantLabel;

  /// Cle d'unicite : un meme produit avec une variante differente = 2 lignes.
  String get key => variantId != null ? '$slug#$variantId' : slug;

  int get lineTotal => price * quantity;

  CartLine copyWith({int? quantity}) => CartLine(
        slug: slug,
        title: title,
        price: price,
        quantity: quantity ?? this.quantity,
        posterUrl: posterUrl,
        shopName: shopName,
        variantId: variantId,
        variantLabel: variantLabel,
      );

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'price': price,
        'quantity': quantity,
        'poster_url': posterUrl,
        'shop_name': shopName,
        'variant_id': variantId,
        'variant_label': variantLabel,
      };

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
        slug: asString(json['slug']),
        title: asString(json['title']),
        price: asInt(json['price']),
        quantity: asInt(json['quantity'], 1),
        posterUrl: asStringOrNull(json['poster_url']),
        shopName: asStringOrNull(json['shop_name']),
        variantId: asIntOrNull(json['variant_id']),
        variantLabel: asStringOrNull(json['variant_label']),
      );
}
