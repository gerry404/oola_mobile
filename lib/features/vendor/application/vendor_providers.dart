import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import '../data/vendor_repository.dart';
import '../domain/vendor_models.dart';

final vendorRepositoryProvider = Provider<VendorRepository>((ref) {
  return VendorRepository(ref.watch(dioProvider));
});

final vendorDashboardProvider = FutureProvider<VendorDashboard>((ref) {
  return ref.watch(vendorRepositoryProvider).dashboard();
});

final vendorProductsProvider =
    FutureProvider<Paginated<VendorProduct>>((ref) {
  return ref.watch(vendorRepositoryProvider).products();
});

final vendorWalletProvider = FutureProvider<VendorWallet>((ref) {
  return ref.watch(vendorRepositoryProvider).wallet();
});

/// Commandes vendeur par groupe (preparing / delivering / delivered).
final vendorOrdersProvider =
    FutureProvider.family<Paginated<OrderSummary>, String>((ref, group) {
  return ref.watch(vendorRepositoryProvider).orders(group: group);
});
