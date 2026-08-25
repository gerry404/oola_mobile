import 'package:dio/dio.dart';

/// Erreur normalisee de l'API OOLAshop.
///
/// Le backend Laravel renvoie `{ "message": "...", "errors": { champ: [..] } }`.
/// On expose un objet simple a afficher, et les erreurs de validation par champ.
class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.errors = const {},
    this.isNetwork = false,
  });

  final String message;
  final int? statusCode;
  final Map<String, List<String>> errors;
  final bool isNetwork;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isValidation => statusCode == 422;

  /// Premier message d'erreur de validation pour un champ donne, si present.
  String? fieldError(String field) =>
      errors[field]?.isNotEmpty == true ? errors[field]!.first : null;

  factory ApiException.fromDio(DioException e) {
    // Pas de reponse serveur => probleme reseau.
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.response == null) {
      return ApiException(
        'Connexion impossible. Verifiez votre reseau.',
        isNetwork: true,
      );
    }

    final data = e.response?.data;
    String message = 'Une erreur est survenue.';
    final Map<String, List<String>> fieldErrors = {};

    if (data is Map) {
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        message = data['message'] as String;
      }
      if (data['errors'] is Map) {
        (data['errors'] as Map).forEach((key, value) {
          if (value is List) {
            fieldErrors[key.toString()] =
                value.map((v) => v.toString()).toList();
          }
        });
      }
    }

    return ApiException(
      message,
      statusCode: e.response?.statusCode,
      errors: fieldErrors,
    );
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
