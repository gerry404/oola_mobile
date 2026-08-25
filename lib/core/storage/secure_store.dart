import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stockage chiffre (Keystore Android / Keychain iOS).
///
/// Contient le token Sanctum et les preferences sensibles (biometrie activee,
/// identifiant de l'appareil de confiance). Jamais en clair, conformement au
/// cahier des charges (section 3.1).
class SecureStore {
  SecureStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _kToken = 'oola.token';
  static const _kBiometricEnabled = 'oola.biometric_enabled';
  static const _kDeviceId = 'oola.device_id';
  static const _kLastEmail = 'oola.last_email';

  Future<String?> readToken() => _storage.read(key: _kToken);
  Future<void> writeToken(String token) =>
      _storage.write(key: _kToken, value: token);
  Future<void> clearToken() => _storage.delete(key: _kToken);

  Future<bool> isBiometricEnabled() async =>
      (await _storage.read(key: _kBiometricEnabled)) == '1';
  Future<void> setBiometricEnabled(bool enabled) =>
      _storage.write(key: _kBiometricEnabled, value: enabled ? '1' : '0');

  Future<String?> readDeviceId() => _storage.read(key: _kDeviceId);
  Future<void> writeDeviceId(String id) =>
      _storage.write(key: _kDeviceId, value: id);

  Future<String?> readLastEmail() => _storage.read(key: _kLastEmail);
  Future<void> writeLastEmail(String email) =>
      _storage.write(key: _kLastEmail, value: email);

  /// Efface tout a la deconnexion.
  Future<void> wipe() => _storage.deleteAll();
}

/// Instance par defaut avec options durcies.
FlutterSecureStorage buildSecureStorage() => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );
