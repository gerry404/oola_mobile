import '../../core/utils/parse.dart';
import 'flash_sale.dart';

/// Carte produit utilisee par le feed, la recherche et les rails.
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
    this.shopPhone,
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
  final String? shopPhone;
  final String? videoUrl;
  final String? posterUrl;

  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;

  /// Prix effectif (promo si vente flash active).
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
        shopPhone: asStringOrNull(json['shop_phone']),
        videoUrl: asStringOrNull(json['video_url']),
        posterUrl: asStringOrNull(json['poster_url']),
      );
}
