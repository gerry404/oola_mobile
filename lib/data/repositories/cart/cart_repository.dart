import 'package:flutter/foundation.dart';

import '../../../domain/models/cart_line.dart';
import '../../services/local_store_service.dart';

/// Panier + favoris, persistes localement (disponibles hors ligne).
///
/// ChangeNotifier : les ViewModels/ecrans ecoutent les changements.
class CartRepository extends ChangeNotifier {
  CartRepository({required LocalStoreService store}) : _store = store {
    _lines = _store.readList(_cartKey).map(CartLine.fromJson).toList();
    _favorites = _store.readList(_favKey).map(FavoriteItem.fromJson).toList();
  }

  final LocalStoreService _store;
  static const _cartKey = 'cart_lines';
  static const _favKey = 'favorites';

  List<CartLine> _lines = [];
  List<FavoriteItem> _favorites = [];

  List<CartLine> get lines => List.unmodifiable(_lines);
  List<FavoriteItem> get favorites => List.unmodifiable(_favorites);

  int get count => _lines.fold(0, (s, l) => s + l.quantity);
  int get subtotal => _lines.fold(0, (s, l) => s + l.lineTotal);
  bool inCart(String slug) => _lines.any((l) => l.slug == slug);
  bool isFavorite(String slug) => _favorites.any((f) => f.slug == slug);

  void _persistCart() {
    _store.writeList(_cartKey, _lines.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  void _persistFav() {
    _store.writeList(_favKey, _favorites.map((e) => e.toJson()).toList());
    notifyListeners();
  }

  void addToCart(CartLine line, {int quantity = 1}) {
    final idx = _lines.indexWhere((l) => l.key == line.key);
    if (idx >= 0) {
      _lines[idx] = _lines[idx].copyWith(quantity: _lines[idx].quantity + quantity);
    } else {
      _lines = [..._lines, line.copyWith(quantity: quantity)];
    }
    _persistCart();
  }

  void setQuantity(String key, int quantity) {
    if (quantity <= 0) {
      removeFromCart(key);
      return;
    }
    _lines = [
      for (final l in _lines) if (l.key == key) l.copyWith(quantity: quantity) else l,
    ];
    _persistCart();
  }

  void removeFromCart(String key) {
    _lines = _lines.where((l) => l.key != key).toList();
    _persistCart();
  }

  void clearCart() {
    _lines = [];
    _persistCart();
  }

  /// Bascule un favori ; renvoie true si desormais favori.
  bool toggleFavorite(FavoriteItem item) {
    if (isFavorite(item.slug)) {
      _favorites = _favorites.where((f) => f.slug != item.slug).toList();
      _persistFav();
      return false;
    }
    _favorites = [item, ..._favorites];
    _persistFav();
    return true;
  }

  void removeFavorite(String slug) {
    _favorites = _favorites.where((f) => f.slug != slug).toList();
    _persistFav();
  }
}
