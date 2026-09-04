/// Chemins de navigation.
abstract final class Routes {
  static const home = '/';
  static const login = '/login';
  static const onboarding = '/onboarding';

  static const product = '/product'; // /product/:slug
  static String productWith(String slug) => '$product/$slug';

  static const cart = '/cart';
  static const checkout = '/checkout';

  static const order = '/order'; // /order/:reference
  static String orderWith(String reference) => '$order/$reference';

  static const orders = '/orders';
  static const addresses = '/addresses';
  static const favorites = '/favorites';
  static const notifications = '/notifications';
  static const security = '/security';

  static const addProduct = '/vendor/product/new';
}
