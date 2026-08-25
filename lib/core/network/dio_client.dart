import 'package:dio/dio.dart';

import '../config/env.dart';
import '../storage/secure_store.dart';

/// Fabrique le client Dio configure pour l'API OOLAshop.
///
/// - Ajoute le Bearer token Sanctum a chaque requete authentifiee.
/// - Sur 401, purge le token (session expiree) et notifie via [onUnauthorized].
/// - Les statuts >= 400 levent une DioException, convertie en [ApiException]
///   par les repositories via `ApiException.fromDio`.
/// - Timeouts adaptes a une connexion mobile moyenne (cahier des charges 6.2).
Dio buildDio({
  required SecureStore store,
  void Function()? onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBase,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 60), // uploads video
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await store.readToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await store.clearToken();
          onUnauthorized?.call();
        }
        handler.next(error);
      },
    ),
  );

  if (Env.enableNetworkLogs) {
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  return dio;
}
