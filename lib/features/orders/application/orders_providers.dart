import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../shared/models/delivery_zone.dart';
import '../../../shared/models/order.dart';
import '../data/orders_repository.dart';

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository(ref.watch(dioProvider));
});

/// Zones de livraison (mises en cache pour la session).
final deliveryZonesProvider = FutureProvider<List<DeliveryZone>>((ref) {
  return ref.watch(ordersRepositoryProvider).deliveryZones();
});

/// Detail + suivi d'une commande (rafraichi a l'ouverture de l'ecran).
final orderProvider =
    FutureProvider.family<OrderDetail, String>((ref, reference) {
  return ref.watch(ordersRepositoryProvider).order(reference);
});

/// Historique des commandes du client connecte.
final myOrdersProvider = FutureProvider((ref) {
  return ref.watch(ordersRepositoryProvider).myOrders();
});
