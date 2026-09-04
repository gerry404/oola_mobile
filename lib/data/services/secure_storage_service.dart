import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/result.dart';

/// Stockage chiffre (Keystore Android / Keychain iOS) : token Sanctum et
/// preferences sensibles (biometrie, dernier email).
class SecureStorageService {
  SecureStorageService([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions:
                  IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  final FlutterSecureStorage _storage;

  static const _kToken = 'oola.token';
  static const _kBiometric = 'oola.biometric_enabled';
  static const _kLastEmail = 'oola.last_email';

  Future<Result<String?>> fetchToken() async {
    try {
      return Result.ok(await _storage.read(key: _kToken));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<void>> saveToken(String? token) async {
    try {
      if (token == null) {
        await _storage.delete(key: _kToken);
      } else {
        await _storage.write(key: _kToken, value: token);
      }
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<bool> isBiometricEnabled() async =>
      (await _storage.read(key: _kBiometric)) == '1';

  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _kBiometric, value: enabled ? '1' : '0');

  Future<String?> lastEmail() => _storage.read(key: _kLastEmail);
  Future<void> saveLastEmail(String email) =>
      _storage.write(key: _kLastEmail, value: email);
}
