import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../../../config/env.dart';
import '../../../utils/result.dart';
import 'api_exception.dart';

/// Fournit l'entete Authorization (defini par le repository d'auth).
typedef AuthHeaderProvider = String? Function();

/// Transport HTTP unique de l'application.
///
/// Suit l'architecture de reference : le client ne contient aucune logique
/// metier, il transporte les requetes et renvoie des [Result]. Les repositories
/// mappent le JSON vers les modeles du domaine. L'entete d'authentification est
/// fournie par un callback ([authHeaderProvider]) branche par le repository
/// d'auth, evitant tout couplage direct.
class ApiClient {
  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: Env.apiBase,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                sendTimeout: const Duration(seconds: 60),
                headers: {'Accept': 'application/json'},
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final header = _authHeaderProvider?.call();
          if (header != null) {
            options.headers['Authorization'] = header;
          }
          handler.next(options);
        },
      ),
    );
    if (Env.networkLogs) {
      _dio.interceptors.add(LogInterceptor(responseBody: true));
    }
  }

  final Dio _dio;
  final _log = Logger('ApiClient');

  AuthHeaderProvider? _authHeaderProvider;
  set authHeaderProvider(AuthHeaderProvider provider) =>
      _authHeaderProvider = provider;

  Future<Result<dynamic>> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<Result<dynamic>> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body));

  Future<Result<dynamic>> patch(String path, {Object? body}) =>
      _send(() => _dio.patch(path, data: body));

  Future<Result<dynamic>> delete(String path) =>
      _send(() => _dio.delete(path));

  /// Envoi multipart (upload de fichier, ex. video produit).
  Future<Result<dynamic>> postMultipart(String path, FormData form) =>
      _send(() => _dio.post(path, data: form));

  Future<Result<dynamic>> _send(Future<Response<dynamic>> Function() run) async {
    try {
      final res = await run();
      return Result.ok(res.data);
    } on DioException catch (e) {
      final ex = ApiException.fromDio(e);
      _log.warning('API ${e.requestOptions.path} -> ${ex.message}');
      return Result.error(ex);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
