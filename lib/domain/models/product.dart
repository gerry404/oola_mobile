import '../../utils/parse.dart';

/// Vente flash active associee a un produit.
class FlashSale {
  const FlashSale({required this.promoPrice, this.endsAt, this.stockRemaining});

  final int promoPrice;
  final DateTime? endsAt;
  final int? stockRemaining;

  factory FlashSale.fromJson(Map<String, dynamic> json) => FlashSale(
        promoPrice: asInt(json['promo_price']),
        endsAt: asDate(json['ends_at']),
        stockRemaining: asIntOrNull(json['stock_remaining']),
      );

  static FlashSale? maybe(dynamic json) =>
      json is Map ? FlashSale.fromJson(asMap(json)) : null;
}

/// Carte produit (feed, recherche, rails).
class ProductCard {
  const ProductCard({
    required this.id,
    required this.slug,
    required this.title,
    required this.price,
    this.isSponsored = false,
    this.flashSale,
    this.shopName,
    this.shopSlug,
    this.videoUrl,
    this.posterUrl,
  });

  final int id;
  final String slug;
  final String title;
  final int price;
  final bool isSponsored;
  final FlashSale? flashSale;
  final String? shopName;
  final String? shopSlug;
  final String? videoUrl;
  final String? posterUrl;

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  int get effectivePrice => flashSale?.promoPrice ?? price;
  bool get onSale => flashSale != null && flashSale!.promoPrice < price;

  factory ProductCard.fromJson(Map<String, dynamic> json) => ProductCard(
        id: asInt(json['id']),
        slug: asString(json['slug']),
        title: asString(json['title']),
        price: asInt(json['price']),
        isSponsored: asBool(json['is_sponsored']),
        flashSale: FlashSale.maybe(json['flash_sale']),
        shopName: asStringOrNull(json['shop_name']),
        shopSlug: asStringOrNull(json['shop_slug']),
        videoUrl: asStringOrNull(json['video_url']),
        posterUrl: asStringOrNull(json['poster_url']),
      );
}

/// Variante produit (taille / couleur + stock).
class ProductVariant {
  const ProductVariant({required this.id, this.size, this.color, this.stock = 0});

  final int id;
  final String? size;
  final String? color;
  final int stock;

  bool get inStock => stock > 0;
  String get label =>
      [size, color].whereType<String>().where((e) => e.isNotEmpty).join(' / ');

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
        id: asInt(json['id']),
        size: asStringOrNull(json['size']),
        color: asStringOrNull(json['color']),
        stock: asInt(json['stock']),
      );
}

/// Caracteristique decoree.
class ProductAttribute {
  const ProductAttribute({
    required this.label,
    required this.value,
    this.unit,
  });

  final String label;
  final String value;
  final String? unit;

  String get display => unit != null && unit!.isNotEmpty ? '$value $unit' : value;

  factory ProductAttribute.fromJson(Map<String, dynamic> json) =>
      ProductAttribute(
        label: asString(json['label'], asString(json['key'])),
        value: asString(json['value']),
        unit: asStringOrNull(json['unit']),
      );
}

/// Fiche produit complete.
class ProductDetail {
  const ProductDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.price,
    this.description,
    this.flashSale,
    this.shopName,
    this.shopSlug,
    this.categoryName,
    this.videoUrl,
    this.posterUrl,
    this.brand,
    this.condition,
    this.warrantyMonths,
    this.originCountry,
    this.ratingAverage = 0,
    this.ratingCount = 0,
    this.attributes = const [],
    this.variants = const [],
  });

  final int id;
  final String slug;
  final String title;
  final int price;
  final String? description;
  final FlashSale? flashSale;
  final String? shopName;
  final String? shopSlug;
  final String? categoryName;
  final String? videoUrl;
  final String? posterUrl;
  final String? brand;
  final String? condition;
  final int? warrantyMonths;
  final String? originCountry;
  final double ratingAverage;
  final int ratingCount;
  final List<ProductAttribute> attributes;
  final List<ProductVariant> variants;

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  int get effectivePrice => flashSale?.promoPrice ?? price;
  bool get onSale => flashSale != null && flashSale!.promoPrice < price;
  bool get hasVariants => variants.isNotEmpty;

  String get conditionLabel => switch (condition) {
        'new' => 'Neuf',
        'used' => 'Occasion',
        'refurbished' => 'Reconditionne',
        _ => '',
      };

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    final cat = json['category'] is Map ? asMap(json['category']) : null;
    final rating = asMap(json['rating']);
    return ProductDetail(
      id: asInt(json['id']),
      slug: asString(json['slug']),
      title: asString(json['title']),
      price: asInt(json['price']),
      description: asStringOrNull(json['description']),
      flashSale: FlashSale.maybe(json['flash_sale']),
      shopName: asStringOrNull(json['shop_name']),
      shopSlug: asStringOrNull(json['shop_slug']),
      categoryName: cat != null ? asStringOrNull(cat['name']) : null,
      videoUrl: asStringOrNull(json['video_url']),
      posterUrl: asStringOrNull(json['poster_url']),
      brand: asStringOrNull(json['brand']),
      condition: asStringOrNull(json['condition']),
      warrantyMonths: asIntOrNull(json['warranty_months']),
      originCountry: asStringOrNull(json['origin_country']),
      ratingAverage: asDouble(rating['average']),
      ratingCount: asInt(rating['count']),
      attributes: asList(json['attributes'])
          .map((e) => ProductAttribute.fromJson(asMap(e)))
          .toList(),
      variants: asList(json['variants'])
          .map((e) => ProductVariant.fromJson(asMap(e)))
          .toList(),
    );
  }
}
