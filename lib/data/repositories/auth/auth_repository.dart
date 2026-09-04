import 'package:flutter/foundation.dart';

import '../../../domain/models/user.dart';
import '../../../utils/result.dart';

/// Source de verite de la session (ChangeNotifier : le router ecoute pour
/// rediriger a la connexion/deconnexion).
abstract class AuthRepository extends ChangeNotifier {
  /// true si une session valide existe (charge le token stocke au 1er appel).
  Future<bool> get isAuthenticated;

  /// Utilisateur courant (null si non charge / deconnecte).
  User? get currentUser;

  /// Etape 1 acheteur : demande le code OTP par email.
  Future<Result<void>> requestClientCode(String email);

  /// Etape 2 acheteur : verifie l'OTP.
  ///
  /// Si le compte est privilegie (vendeur/admin/livreur), la session n'est PAS
  /// ouverte (l'appelant doit demander le mot de passe) mais l'utilisateur est
  /// renvoye pour lire son role.
  Future<Result<User>> clientLogin({
    required String email,
    required String code,
  });

  /// Connexion par mot de passe (pro, ou 2e facteur d'un compte privilegie).
  Future<Result<void>> loginWithPassword({
    required String identifier,
    required String password,
  });

  /// Recharge l'utilisateur courant (`/auth/me`).
  Future<Result<void>> loadCurrentUser();

  /// Deconnexion : verrouille (garde le token) si la biometrie est active,
  /// sinon deconnexion complete.
  Future<Result<void>> logout();

  /// Deconnexion complete (revoque le token, desactive la biometrie).
  Future<Result<void>> logoutFull();

  // ----- Biometrie -----
  Future<bool> isBiometricEnabled();
  Future<Result<void>> setBiometricEnabled(bool enabled);

  /// true si une session memorisee peut etre deverrouillee par empreinte.
  Future<bool> canBiometricLogin();

  /// Deverrouille la session memorisee par empreinte.
  Future<Result<void>> biometricLogin();
}
