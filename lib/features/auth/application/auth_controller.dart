import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../shared/models/user.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

enum AuthStatus { unknown, authenticated, unauthenticated }

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

  /// Connexion acheteur (OTP). Etape 1 : demande du code.
  Future<void> requestClientCode(String identifier) =>
      _repo.clientLoginStart(identifier: identifier);

  /// Connexion acheteur. Etape 2 : verification et ouverture de session.
  Future<void> clientLogin({
    required String identifier,
    required String code,
    String? password,
  }) async {
    final store = ref.read(secureStoreProvider);
    final res = await _repo.clientLogin(
      identifier: identifier,
      code: code,
      password: password,
    );
    await store.writeToken(res.token);
    await store.writeLastEmail(identifier);
    state = AuthState(status: AuthStatus.authenticated, user: res.user);
  }

  /// Connexion vendeur / livreur / admin (email + mot de passe).
  Future<void> login({required String email, required String password}) async {
    final store = ref.read(secureStoreProvider);
    final res = await _repo.login(email: email, password: password);
    await store.writeToken(res.token);
    await store.writeLastEmail(email);
    state = AuthState(status: AuthStatus.authenticated, user: res.user);
  }

  Future<void> logout() async {
    await _repo.logout();
    await ref.read(secureStoreProvider).clearToken();
    state = const AuthState.signedOut();
  }

  void _onSessionExpired() {
    if (state.status == AuthStatus.authenticated) {
      state = const AuthState.signedOut();
    }
  }
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
