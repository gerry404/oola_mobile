import 'package:logging/logging.dart';

import '../../../domain/models/user.dart';
import '../../../utils/parse.dart';
import '../../../utils/result.dart';
import '../../services/api/api_client.dart';
import '../../services/biometric_service.dart';
import '../../services/secure_storage_service.dart';
import 'auth_repository.dart';

class AuthRepositoryRemote extends AuthRepository {
  AuthRepositoryRemote({
    required ApiClient apiClient,
    required SecureStorageService storage,
    required BiometricService biometric,
  })  : _api = apiClient,
        _storage = storage,
        _biometric = biometric {
    _api.authHeaderProvider = () =>
        _token != null && _token!.isNotEmpty ? 'Bearer $_token' : null;
  }

  final ApiClient _api;
  final SecureStorageService _storage;
  final BiometricService _biometric;
  final _log = Logger('AuthRepositoryRemote');

  String? _token;
  bool? _authenticated;
  User? _user;

  @override
  User? get currentUser => _user;

  @override
  Future<bool> get isAuthenticated async {
    if (_authenticated != null) return _authenticated!;
    final result = await _storage.fetchToken();
    switch (result) {
      case Ok<String?>():
        _token = result.value;
        _authenticated = result.value != null && result.value!.isNotEmpty;
      case Error<String?>():
        _log.severe('Lecture du token echouee', result.error);
        _authenticated = false;
    }
    return _authenticated ?? false;
  }

  @override
  Future<Result<void>> requestClientCode(String email) async {
    final res = await _api.post('/auth/client/login-start', body: {'email': email});
    return switch (res) {
      Ok() => const Result.ok(null),
      Error(:final error) => Result.error(error),
    };
  }

  @override
  Future<Result<User>> clientLogin({
    required String email,
    required String code,
  }) async {
    final res =
        await _api.post('/auth/client/login', body: {'email': email, 'code': code});
    switch (res) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        final map = asMap(value);
        final user = User.fromJson(asMap(map['user']));
        final token = asStringOrNull(map['token']);
        // Compte privilegie : on n'ouvre pas la session (mot de passe requis).
        if (user.role.isPrivileged) {
          return Result.ok(user);
        }
        await _persistSession(token, user, email);
        return Result.ok(user);
    }
  }

  @override
  Future<Result<void>> loginWithPassword({
    required String identifier,
    required String password,
  }) async {
    final res = await _api
        .post('/auth/login', body: {'identifier': identifier, 'password': password});
    switch (res) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        final map = asMap(value);
        final user = User.fromJson(asMap(map['user']));
        await _persistSession(asStringOrNull(map['token']), user, identifier);
        return const Result.ok(null);
    }
  }

  @override
  Future<Result<void>> loadCurrentUser() async {
    final res = await _api.get('/auth/me');
    switch (res) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        _user = User.fromJson(asMap(value));
        _authenticated = true;
        notifyListeners();
        return const Result.ok(null);
    }
  }

  @override
  Future<Result<void>> logout() async {
    // Si la biometrie est active : verrouillage (on garde le token).
    if (await isBiometricEnabled()) {
      _authenticated = false;
      _user = null;
      notifyListeners();
      return const Result.ok(null);
    }
    return logoutFull();
  }

  @override
  Future<Result<void>> logoutFull() async {
    await _api.post('/auth/logout');
    await _storage.setBiometricEnabled(false);
    final saved = await _storage.saveToken(null);
    _token = null;
    _user = null;
    _authenticated = false;
    notifyListeners();
    return saved;
  }

  @override
  Future<bool> isBiometricEnabled() => _storage.isBiometricEnabled();

  @override
  Future<Result<void>> setBiometricEnabled(bool enabled) async {
    await _storage.setBiometricEnabled(enabled);
    return const Result.ok(null);
  }

  @override
  Future<bool> canBiometricLogin() async {
    final token = (await _storage.fetchToken());
    final hasToken = token is Ok<String?> && token.value != null;
    if (!hasToken) return false;
    if (!await isBiometricEnabled()) return false;
    return await _biometric.isAvailable && await _biometric.hasEnrolled;
  }

  @override
  Future<Result<void>> biometricLogin() async {
    final tokenResult = await _storage.fetchToken();
    if (tokenResult is! Ok<String?> || tokenResult.value == null) {
      return Result.error(Exception('Aucune session memorisee.'));
    }
    final auth =
        await _biometric.authenticate(reason: 'Connectez-vous a OOLAshop');
    if (auth != BiometricResult.success) {
      return Result.error(Exception('Verification biometrique annulee.'));
    }
    _token = tokenResult.value;
    final me = await loadCurrentUser();
    if (me is Error) {
      // Token invalide : on nettoie.
      await _storage.saveToken(null);
      _token = null;
      _authenticated = false;
    }
    return me;
  }

  Future<void> _persistSession(String? token, User user, String email) async {
    _token = token;
    _user = user;
    _authenticated = true;
    if (token != null) await _storage.saveToken(token);
    await _storage.saveLastEmail(email);
    notifyListeners();
  }
}
