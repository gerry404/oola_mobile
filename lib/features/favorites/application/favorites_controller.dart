import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/parse.dart';

/// Produit favori (infos minimales pour l'affichage de la liste).
class FavoriteItem {
  const FavoriteItem({
    required this.slug,
    required this.title,
    required this.price,
    this.posterUrl,
    this.shopName,
  });

  final String slug;
  final String title;
  final int price;
  final String? posterUrl;
  final String? shopName;

  Map<String, dynamic> toJson() => {
        'slug': slug,
        'title': title,
        'price': price,
        'poster_url': posterUrl,
        'shop_name': shopName,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
        slug: asString(json['slug']),
        title: asString(json['title']),
        price: asInt(json['price']),
        posterUrl: asStringOrNull(json['poster_url']),
        shopName: asStringOrNull(json['shop_name']),
      );
}

/// Favoris persistes localement (Hive).
class FavoritesController extends Notifier<List<FavoriteItem>> {
  static const _key = 'favorites';

  @override
  List<FavoriteItem> build() {
    return ref
        .read(localStoreProvider)
        .readList(_key)
        .map(FavoriteItem.fromJson)
        .toList();
  }

  void _persist(List<FavoriteItem> items) {
    state = items;
    ref.read(localStoreProvider).writeList(_key, items.map((e) => e.toJson()).toList());
  }

  bool has(String slug) => state.any((f) => f.slug == slug);

  /// Bascule le favori ; renvoie true si desormais favori.
  bool toggle(FavoriteItem item) {
    if (has(item.slug)) {
      _persist(state.where((f) => f.slug != item.slug).toList());
      return false;
    }
    _persist([item, ...state]);
    return true;
  }

  void remove(String slug) => _persist(state.where((f) => f.slug != slug).toList());
}

final favoritesControllerProvider =
    NotifierProvider<FavoritesController, List<FavoriteItem>>(
        FavoritesController.new);
