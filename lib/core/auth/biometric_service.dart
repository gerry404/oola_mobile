import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Resultat d'une tentative d'authentification biometrique.
enum BiometricResult { success, failed, unavailable, notEnrolled, canceled }

/// Service de connexion par empreinte / reconnaissance faciale.
///
/// Cahier des charges section 3 : deverrouillage de l'app et re-verification
/// avant les operations sensibles (paiement, retrait, changement de mot de
/// passe, suppression du compte).
class BiometricService {
  BiometricService([LocalAuthentication? auth])
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// L'appareil possede-t-il un capteur biometrique exploitable ?
  Future<bool> get isAvailable async {
    try {
      final supported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return supported && canCheck;
    } on PlatformException {
      return false;
    }
  }

  /// Au moins une empreinte / un visage est-il enregistre sur l'appareil ?
  Future<bool> get hasEnrolled async {
    try {
      final list = await _auth.getAvailableBiometrics();
      return list.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Demande une authentification biometrique.
  ///
  /// [reason] est affiche a l'utilisateur (ex. "Confirmez pour payer").
  /// [biometricOnly] force l'empreinte/visage sans repli sur le code appareil
  /// pour les operations les plus sensibles.
  Future<BiometricResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      if (!await isAvailable) return BiometricResult.unavailable;
      if (!await hasEnrolled) return BiometricResult.notEnrolled;

      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return ok ? BiometricResult.success : BiometricResult.canceled;
    } on PlatformException {
      return BiometricResult.failed;
    }
  }
}
