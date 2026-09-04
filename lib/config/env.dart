/// Configuration d'environnement injectee au build via --dart-define.
///
///   flutter run --dart-define=OOLA_API_BASE=http://10.0.2.2:8000/api
abstract final class Env {
  /// Base de l'API Laravel (Sanctum), sans slash final.
  static const String apiBase = String.fromEnvironment(
    'OOLA_API_BASE',
    defaultValue: 'https://oolashop.com/api',
  );

  /// Origine du site (URLs de partage).
  static const String siteOrigin = String.fromEnvironment(
    'OOLA_SITE_ORIGIN',
    defaultValue: 'https://oolashop.com',
  );

  /// Logs reseau detailles (false en release).
  static const bool networkLogs = bool.fromEnvironment(
    'OOLA_NET_LOGS',
    defaultValue: false,
  );
}
