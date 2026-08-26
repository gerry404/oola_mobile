import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../shared/models/address.dart';
import '../../../shared/models/app_notification.dart';
import '../data/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(ref.watch(dioProvider));
});

/// Adresses du client.
final addressesProvider = FutureProvider<List<Address>>((ref) {
  return ref.watch(accountRepositoryProvider).addresses();
});

/// Notifications in-app.
final notificationsProvider = FutureProvider<List<AppNotification>>((ref) {
  return ref.watch(accountRepositoryProvider).notifications();
});
