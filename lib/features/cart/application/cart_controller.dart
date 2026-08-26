import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/cart_line.dart';

/// Panier persiste localement (Hive), disponible hors ligne.
class CartController extends Notifier<List<CartLine>> {
  static const _key = 'cart_lines';

  @override
  List<CartLine> build() {
    final store = ref.read(localStoreProvider);
    return store.readList(_key).map(CartLine.fromJson).toList();
  }

  void _persist(List<CartLine> lines) {
    state = lines;
    ref.read(localStoreProvider).writeList(_key, lines.map((e) => e.toJson()).toList());
  }

  /// Ajoute une ligne (ou incremente si deja presente).
  void add(CartLine line, {int quantity = 1}) {
    final lines = [...state];
    final idx = lines.indexWhere((l) => l.key == line.key);
    if (idx >= 0) {
      lines[idx] = lines[idx].copyWith(quantity: lines[idx].quantity + quantity);
    } else {
      lines.add(line.copyWith(quantity: quantity));
    }
    _persist(lines);
  }

  void setQuantity(String key, int quantity) {
    if (quantity <= 0) {
      remove(key);
      return;
    }
    _persist([
      for (final l in state) if (l.key == key) l.copyWith(quantity: quantity) else l,
    ]);
  }

  void increment(String key) {
    final l = state.firstWhere((e) => e.key == key);
    setQuantity(key, l.quantity + 1);
  }

  void decrement(String key) {
    final l = state.firstWhere((e) => e.key == key);
    setQuantity(key, l.quantity - 1);
  }

  void remove(String key) => _persist(state.where((l) => l.key != key).toList());

  void clear() => _persist([]);

  bool contains(String slug) => state.any((l) => l.slug == slug);
}

final cartControllerProvider =
    NotifierProvider<CartController, List<CartLine>>(CartController.new);

/// Nombre total d'articles dans le panier (pour le badge).
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartControllerProvider).fold<int>(0, (sum, l) => sum + l.quantity);
});

/// Sous-total du panier (FCFA).
final cartSubtotalProvider = Provider<int>((ref) {
  return ref.watch(cartControllerProvider).fold<int>(0, (sum, l) => sum + l.lineTotal);
});
