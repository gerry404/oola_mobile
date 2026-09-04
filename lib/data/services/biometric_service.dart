import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Resultat d'une tentative biometrique.
enum BiometricResult { success, failed, unavailable, notEnrolled, canceled }

/// Authentification par empreinte / visage (local_auth).
class BiometricService {
  BiometricService([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<bool> get isAvailable async {
    try {
      return await _auth.isDeviceSupported() && await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> get hasEnrolled async {
    try {
      return (await _auth.getAvailableBiometrics()).isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<BiometricResult> authenticate({required String reason}) async {
    try {
      if (!await isAvailable) return BiometricResult.unavailable;
      if (!await hasEnrolled) return BiometricResult.notEnrolled;
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(stickyAuth: true),
      );
      return ok ? BiometricResult.success : BiometricResult.canceled;
    } on PlatformException {
      return BiometricResult.failed;
    }
  }
}
