import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import '../data/delivery_repository.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository(ref.watch(dioProvider));
});

/// File des livraisons disponibles.
final deliveryQueueProvider = FutureProvider<Paginated<OrderSummary>>((ref) {
  return ref.watch(deliveryRepositoryProvider).queue();
});
