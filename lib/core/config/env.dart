/// Configuration d'environnement compilee.
///
/// La base URL est injectee au build via --dart-define pour ne pas coder
/// l'URL de prod en dur. Par defaut : la plateforme OOLAshop en ligne.
///
/// Exemple :
///   flutter run --dart-define=OOLA_API_BASE=http://10.0.2.2:8000/api
class Env {
  const Env._();

  /// Base de l'API Laravel (Sanctum). Termine par /api, sans slash final.
  static const String apiBase = String.fromEnvironment(
    'OOLA_API_BASE',
    defaultValue: 'https://oolashop.com/api',
  );

  /// Origine du site (pour construire les URLs de partage produit).
  static const String siteOrigin = String.fromEnvironment(
    'OOLA_SITE_ORIGIN',
    defaultValue: 'https://oolashop.com',
  );

  /// Active les logs reseau detailles (a laisser false en release).
  static const bool enableNetworkLogs = bool.fromEnvironment(
    'OOLA_NET_LOGS',
    defaultValue: false,
  );

  static bool get isProd => apiBase.startsWith('https://oolashop.com');
}
