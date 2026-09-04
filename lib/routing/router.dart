import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/auth/auth_repository.dart';
import '../data/services/local_store_service.dart';
import '../ui/account/view_models/addresses_viewmodel.dart';
import '../ui/account/view_models/my_orders_viewmodel.dart';
import '../ui/account/view_models/notifications_viewmodel.dart';
import '../ui/account/widgets/addresses_screen.dart';
import '../ui/account/widgets/favorites_screen.dart';
import '../ui/account/widgets/my_orders_screen.dart';
import '../ui/account/widgets/notifications_screen.dart';
import '../ui/account/widgets/security_screen.dart';
import '../ui/auth/login/view_models/login_viewmodel.dart';
import '../ui/auth/login/widgets/login_screen.dart';
import '../ui/auth/onboarding/widgets/onboarding_screen.dart';
import '../ui/cart/widgets/cart_screen.dart';
import '../ui/checkout/view_models/checkout_viewmodel.dart';
import '../ui/checkout/widgets/checkout_screen.dart';
import '../ui/core/ui/root_screen.dart';
import '../ui/order/view_models/order_viewmodel.dart';
import '../ui/order/widgets/order_screen.dart';
import '../ui/product/view_models/product_viewmodel.dart';
import '../ui/product/widgets/product_screen.dart';
import '../ui/vendor/view_models/add_product_viewmodel.dart';
import '../ui/vendor/widgets/add_product_screen.dart';
import 'routes.dart';

/// go_router : ecoute [AuthRepository] pour rediriger a la (de)connexion.
/// Les ViewModels sont construits ici avec leurs dependances (context.read).
GoRouter appRouter(AuthRepository authRepository) => GoRouter(
      initialLocation: Routes.home,
      refreshListenable: authRepository,
      redirect: _redirect,
      routes: [
        GoRoute(path: Routes.home, builder: (_, __) => const RootScreen()),
        GoRoute(
          path: Routes.onboarding,
          builder: (context, __) => OnboardingScreen(
            onDone: () async {
              await context.read<LocalStoreService>().markOnboardingSeen();
              if (context.mounted) context.go(Routes.login);
            },
          ),
        ),
        GoRoute(
          path: Routes.login,
          builder: (context, __) => LoginScreen(
              viewModel: LoginViewModel(authRepository: context.read())),
        ),
        GoRoute(
          path: '${Routes.product}/:slug',
          builder: (context, state) => ProductScreen(
            viewModel: ProductViewModel(
              catalogRepository: context.read(),
              slug: state.pathParameters['slug']!,
            ),
          ),
        ),
        GoRoute(
          path: Routes.cart,
          builder: (_, __) => const CartScreen(asTab: false),
        ),
        GoRoute(
          path: Routes.checkout,
          builder: (context, __) => CheckoutScreen(
            viewModel: CheckoutViewModel(
              ordersRepository: context.read(),
              cartRepository: context.read(),
              biometric: context.read(),
              authRepository: context.read(),
            ),
          ),
        ),
        GoRoute(
          path: '${Routes.order}/:reference',
          builder: (context, state) => OrderScreen(
            viewModel: OrderViewModel(
              ordersRepository: context.read(),
              reference: state.pathParameters['reference']!,
            ),
          ),
        ),
        GoRoute(
          path: Routes.orders,
          builder: (context, __) => MyOrdersScreen(
              viewModel: MyOrdersViewModel(ordersRepository: context.read())),
        ),
        GoRoute(
          path: Routes.addresses,
          builder: (context, __) => AddressesScreen(
              viewModel: AddressesViewModel(accountRepository: context.read())),
        ),
        GoRoute(
          path: Routes.favorites,
          builder: (_, __) => const FavoritesScreen(),
        ),
        GoRoute(
          path: Routes.notifications,
          builder: (context, __) => NotificationsScreen(
              viewModel:
                  NotificationsViewModel(accountRepository: context.read())),
        ),
        GoRoute(
          path: Routes.security,
          builder: (_, __) => const SecurityScreen(),
        ),
        GoRoute(
          path: Routes.addProduct,
          builder: (context, __) => AddProductScreen(
            viewModel: AddProductViewModel(
              vendorRepository: context.read(),
              catalogRepository: context.read(),
            ),
          ),
        ),
      ],
    );

Future<String?> _redirect(BuildContext context, GoRouterState state) async {
  final loc = state.matchedLocation;
  final onboardingSeen = context.read<LocalStoreService>().onboardingSeen;
  final loggedIn = await context.read<AuthRepository>().isAuthenticated;

  if (!onboardingSeen && !loggedIn) {
    return loc == Routes.onboarding ? null : Routes.onboarding;
  }
  if (!loggedIn) {
    return loc == Routes.login ? null : Routes.login;
  }
  if (loc == Routes.login || loc == Routes.onboarding) {
    return Routes.home;
  }
  return null;
}
