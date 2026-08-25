import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/client/presentation/client_shell.dart';
import '../features/delivery/presentation/delivery_shell.dart';
import '../features/vendor/presentation/vendor_shell.dart';
import '../shared/models/user.dart';

/// Chemins de navigation.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const clientHome = '/home';
  static const vendorHome = '/vendor';
  static const deliveryHome = '/delivery';
}

/// Pont Riverpod -> go_router : notifie le router a chaque changement de
/// session pour reevaluer les redirections (garde par role).
class _AuthRouterNotifier extends ChangeNotifier {
  _AuthRouterNotifier(this.ref) {
    ref.listen<AuthState>(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
  AuthState get state => ref.read(authControllerProvider);
}

final _routerNotifierProvider = Provider<_AuthRouterNotifier>((ref) {
  final notifier = _AuthRouterNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});

/// Redirige vers l'accueil correspondant au role de l'utilisateur.
String _homeForRole(UserRole? role) {
  switch (role) {
    case UserRole.vendor:
      return Routes.vendorHome;
    case UserRole.delivery:
      return Routes.deliveryHome;
    case UserRole.client:
    case UserRole.admin: // l'admin utilise l'espace acheteur + moderation
    case UserRole.unknown:
    case null:
      return Routes.clientHome;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(_routerNotifierProvider);

  return GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: notifier,
    redirect: (context, goState) {
      final auth = notifier.state;
      final loc = goState.matchedLocation;

      // Session en cours de restauration : on reste sur le splash.
      if (auth.status == AuthStatus.unknown) {
        return loc == Routes.splash ? null : Routes.splash;
      }

      final loggedIn = auth.isAuthenticated;
      final onAuthScreen = loc == Routes.login || loc == Routes.splash;

      if (!loggedIn) {
        return loc == Routes.login ? null : Routes.login;
      }

      // Connecte mais sur un ecran d'auth -> vers son accueil.
      if (onAuthScreen) return _homeForRole(auth.role);

      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: Routes.clientHome,
        builder: (_, __) => const ClientShell(),
      ),
      GoRoute(
        path: Routes.vendorHome,
        builder: (_, __) => const VendorShell(),
      ),
      GoRoute(
        path: Routes.deliveryHome,
        builder: (_, __) => const DeliveryShell(),
      ),
    ],
  );
});
