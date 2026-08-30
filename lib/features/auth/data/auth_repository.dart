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

  /// Demarre la connexion client (acheteur) : envoie un code OTP par email.
  /// Le backend attend le champ `email` (le flux client est base sur l'email).
  Future<void> clientLoginStart({required String email}) async {
    try {
      await _dio.post('/auth/client/login-start', data: {
        'email': email,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Verifie l'OTP et connecte un compte client existant. Renvoie (token, user).
  Future<({String token, User user})> clientLogin({
    required String email,
    required String code,
  }) async {
    try {
      final res = await _dio.post('/auth/client/login', data: {
        'email': email,
        'code': code,
      });
      return _parseAuth(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Connexion pro (vendeur / livreur / admin) : email OU telephone + mot de passe.
  /// Le backend attend le champ `identifier` (email ou telephone).
  Future<({String token, User user})> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'identifier': identifier,
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
