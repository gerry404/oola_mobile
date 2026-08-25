import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/user.dart';

/// Acces reseau aux endpoints d'authentification (Sanctum).
///
/// Flux acheteur : demande d'OTP -> verification -> token. Le premier login
/// declenche l'activation biometrique cote application (cahier des charges 3).
class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  /// Demarre la connexion client : envoie un code OTP par SMS/email.
  /// Le backend indique si le compte existe (login) ou non (inscription).
  Future<void> clientLoginStart({required String identifier}) async {
    try {
      await _dio.post('/auth/client/login-start', data: {
        'identifier': identifier,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Verifie l'OTP et connecte un compte existant. Renvoie (token, user).
  Future<({String token, User user})> clientLogin({
    required String identifier,
    required String code,
    String? password,
    String? deviceId,
  }) async {
    try {
      final res = await _dio.post('/auth/client/login', data: {
        'identifier': identifier,
        if (code.isNotEmpty) 'code': code,
        if (password != null) 'password': password,
        if (deviceId != null) 'device_id': deviceId,
      });
      return _parseAuth(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Connexion generique (vendeur / livreur / admin) par email + mot de passe.
  Future<({String token, User user})> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return _parseAuth(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Recharge l'utilisateur courant a partir du token stocke.
  Future<User> me() async {
    try {
      final res = await _dio.get('/auth/me');
      return User.fromJson(Map<String, dynamic>.from(res.data as Map));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Revoque le token cote serveur.
  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (_) {
      // On ignore : la purge locale du token suffit a deconnecter.
    }
  }

  ({String token, User user}) _parseAuth(dynamic data) {
    final map = Map<String, dynamic>.from(data as Map);
    final token = map['token'] as String;
    final user = User.fromJson(Map<String, dynamic>.from(map['user'] as Map));
    return (token: token, user: user);
  }
}
