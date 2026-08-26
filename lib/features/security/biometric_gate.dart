import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/biometric_service.dart';
import '../../core/providers.dart';
import '../../shared/widgets/app_toast.dart';

/// Porte de securite pour les operations sensibles (cahier des charges §3.2) :
/// paiement, retrait, changement de mot de passe, suppression de compte.
///
/// Si la biometrie est activee et disponible, une verification est demandee.
/// Sinon, l'action est autorisee (repli sur l'authentification classique).
class BiometricGate {
  BiometricGate(this._ref);
  final Ref _ref;

  Future<bool> require(BuildContext context, {required String reason}) async {
    final store = _ref.read(secureStoreProvider);
    final enabled = await store.isBiometricEnabled();
    if (!enabled) return true; // Pas active : on ne bloque pas.

    final service = _ref.read(biometricProvider);
    final result = await service.authenticate(reason: reason);

    switch (result) {
      case BiometricResult.success:
        return true;
      case BiometricResult.unavailable:
      case BiometricResult.notEnrolled:
        // Le capteur n'est plus disponible : on n'empeche pas l'action.
        return true;
      case BiometricResult.failed:
      case BiometricResult.canceled:
        if (context.mounted) {
          showToast(context, 'Verification annulee.');
        }
        return false;
    }
  }
}

final biometricGateProvider = Provider<BiometricGate>((ref) => BiometricGate(ref));
