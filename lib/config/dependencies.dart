import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/account/account_repository.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_remote.dart';
import '../data/repositories/cart/cart_repository.dart';
import '../data/repositories/catalog/catalog_repository.dart';
import '../data/repositories/catalog/catalog_repository_remote.dart';
import '../data/repositories/delivery/delivery_repository.dart';
import '../data/repositories/orders/orders_repository.dart';
import '../data/repositories/vendor/vendor_repository.dart';
import '../data/services/api/api_client.dart';
import '../data/services/biometric_service.dart';
import '../data/services/local_store_service.dart';
import '../data/services/secure_storage_service.dart';

/// Providers de l'application (architecture de reference : injection par
/// `provider`, repositories exposes comme dependances des ViewModels).
List<SingleChildWidget> providers(LocalStoreService localStore) {
  return [
    // ----- Services -----
    Provider(create: (_) => ApiClient()),
    Provider(create: (_) => SecureStorageService()),
    Provider(create: (_) => BiometricService()),
    Provider.value(value: localStore),

    // ----- Repositories -----
    ChangeNotifierProvider(
      create: (context) => AuthRepositoryRemote(
        apiClient: context.read(),
        storage: context.read(),
        biometric: context.read(),
      ) as AuthRepository,
    ),
    Provider(
      create: (context) =>
          CatalogRepositoryRemote(apiClient: context.read()) as CatalogRepository,
    ),
    ChangeNotifierProvider(
      create: (context) => CartRepository(store: context.read()),
    ),
    Provider(create: (context) => OrdersRepository(apiClient: context.read())),
    Provider(create: (context) => AccountRepository(apiClient: context.read())),
    Provider(create: (context) => VendorRepository(apiClient: context.read())),
    Provider(create: (context) => DeliveryRepository(apiClient: context.read())),
  ];
}
