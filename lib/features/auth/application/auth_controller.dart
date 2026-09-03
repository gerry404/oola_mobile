import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/biometric_service.dart';
import '../../../core/providers.dart';
import '../../../shared/models/user.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Resultat de l'etape OTP acheteur.
enum ClientLoginOutcome {
  /// Session ouverte (compte acheteur simple).
  authenticated,

  /// Compte privilegie : le mot de passe est requis en plus de l'OTP.
  passwordRequired,
}

class AuthState {
  const AuthState({required this.status, this.user});

  final AuthStatus status;
  final User? user;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  UserRole? get role => user?.role;

  const AuthState.unknown() : status = AuthStatus.unknown, user = null;
  const AuthState.signedOut()
      : status = AuthStatus.unauthenticated,
        user = null;

  AuthState copyWith({AuthStatus? status, User? user}) =>
      AuthState(status: status ?? this.status, user: user ?? this.user);
}

/// Source de verite de la session utilisateur.
///
/// Au demarrage, tente de restaurer la session depuis le token chiffre.
/// Reagit aux 401 (token expire) en repassant en etat deconnecte.
class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Repasse en deconnecte des qu'un 401 est intercepte par Dio.
    ref.listen(unauthorizedSignalProvider, (prev, next) {
      if (prev != null && next != prev) {
        _onSessionExpired();
      }
    });
    _restore();
    return const AuthState.unknown();
  }

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<void> _restore() async {
    final store = ref.read(secureStoreProvider);
    final token = await store.readToken();
    if (token == null || token.isEmpty) {
      state = const AuthState.signedOut();
      return;
    }
    try {
      final user = await _repo.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await store.clearToken();
      state = const AuthState.signedOut();
    }
  }

  /// Connexion acheteur (OTP). Etape 1 : demande du code par email.
  Future<void> requestClientCode(String email) =>
      _repo.clientLoginStart(email: email);

  /// Connexion acheteur. Etape 2 : verification du code.
  ///
  /// Securite : si le compte est privilegie (vendeur / admin / livreur), l'OTP
  /// seul ne suffit pas -> on renvoie [ClientLoginOutcome.passwordRequired] et
  /// on n'ouvre PAS la session tant que le mot de passe n'est pas fourni.
  Future<ClientLoginOutcome> clientLogin({
    required String email,
    required String code,
  }) async {
    final store = ref.read(secureStoreProvider);
    final res = await _repo.clientLogin(email: email, code: code);

    final role = res.user.role;
    final privileged = role.isVendor || role.isAdmin || role.isDelivery;
    if (privileged) {
      // On ne conserve pas le token OTP : il faudra le mot de passe pour ouvrir.
      return ClientLoginOutcome.passwordRequired;
    }

    await store.writeToken(res.token);
    await store.writeLastEmail(email);
    state = AuthState(status: AuthStatus.authenticated, user: res.user);
    return ClientLoginOutcome.authenticated;
  }

  /// Finalise la connexion d'un compte privilegie apres l'OTP : verifie le
  /// mot de passe (double facteur) puis ouvre la session.
  Future<void> completePrivilegedLogin({
    required String email,
    required String password,
  }) =>
      login(identifier: email, password: password);

  /// Connexion vendeur / livreur / admin (email ou telephone + mot de passe).
  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    final store = ref.read(secureStoreProvider);
    final res = await _repo.login(identifier: identifier, password: password);
    await store.writeToken(res.token);
    await store.writeLastEmail(identifier);
    state = AuthState(status: AuthStatus.authenticated, user: res.user);
  }

  /// Deconnexion.
  ///
  /// Si la biometrie est activee, on ne revoque PAS le token : on verrouille
  /// simplement la session pour permettre une reconnexion rapide par empreinte
  /// (modele "app bancaire"). Sinon, deconnexion complete.
  Future<void> logout() async {
    final store = ref.read(secureStoreProvider);
    if (await store.isBiometricEnabled()) {
      state = const AuthState.signedOut();
      return;
    }
    await _repo.logout();
    await store.clearToken();
    state = const AuthState.signedOut();
  }

  /// Deconnexion complete : revoque le token, efface tout et desactive la
  /// reconnexion biometrique ("utiliser un autre compte").
  Future<void> logoutFull() async {
    await _repo.logout();
    final store = ref.read(secureStoreProvider);
    await store.clearToken();
    await store.setBiometricEnabled(false);
    state = const AuthState.signedOut();
  }

  /// Une session memorisee est-elle deverrouillable par empreinte ?
  /// (token present + biometrie activee et disponible sur l'appareil)
  Future<bool> canBiometricLogin() async {
    final store = ref.read(secureStoreProvider);
    final token = await store.readToken();
    if (token == null || token.isEmpty) return false;
    if (!await store.isBiometricEnabled()) return false;
    final bio = ref.read(biometricProvider);
    return await bio.isAvailable && await bio.hasEnrolled;
  }

  /// Connexion par empreinte : deverrouille la session memorisee.
  /// Renvoie true si la session est ouverte.
  Future<bool> biometricLogin() async {
    final store = ref.read(secureStoreProvider);
    final token = await store.readToken();
    if (token == null || token.isEmpty) return false;

    final res = await ref
        .read(biometricProvider)
        .authenticate(reason: 'Connectez-vous a OOLAshop');
    if (res != BiometricResult.success) return false;

    try {
      final user = await _repo.me();
      state = AuthState(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (_) {
      // Token invalide/expire : on nettoie et on repasse au login classique.
      await store.clearToken();
      state = const AuthState.signedOut();
      return false;
    }
  }

  void _onSessionExpired() {
    if (state.status == AuthStatus.authenticated) {
      state = const AuthState.signedOut();
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
