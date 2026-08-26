import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth/biometric_service.dart';
import 'network/dio_client.dart';
import 'storage/local_store.dart';
import 'storage/secure_store.dart';

/// Providers d'infrastructure partages par toute l'application.

final secureStoreProvider = Provider<SecureStore>((ref) {
  return SecureStore(buildSecureStorage());
});

/// Stockage local (Hive). Injecte depuis main() via un override, car l'ouverture
/// de la box est asynchrone.
final localStoreProvider = Provider<LocalStore>((ref) {
  throw UnimplementedError('localStoreProvider doit etre override dans main()');
});

final biometricProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

/// Client Dio. Sur 401, on invalide la session pour rediriger vers le login.
final dioProvider = Provider<Dio>((ref) {
  final store = ref.watch(secureStoreProvider);
  return buildDio(
    store: store,
    onUnauthorized: () {
      // La redirection est pilotee par l'ecoute de l'etat d'auth dans le router.
      ref.invalidate(_unauthorizedSignalProvider);
    },
  );
});

/// Signal interne incremente a chaque 401 (permet au controleur d'auth de
/// reagir sans dependance circulaire directe).
final _unauthorizedSignalProvider = StateProvider<int>((ref) => 0);

/// Expose le signal 401 en lecture seule.
final unauthorizedSignalProvider =
    Provider<int>((ref) => ref.watch(_unauthorizedSignalProvider));
