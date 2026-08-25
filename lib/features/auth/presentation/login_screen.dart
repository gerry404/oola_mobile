import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../application/auth_controller.dart';

/// Connexion. Deux modes :
///  - Acheteur : identifiant (tel/email) + code recu par message (OTP).
///  - Espace pro (vendeur / livreur / admin) : email + mot de passe.
///
/// L'activation de la biometrie se fera apres la premiere connexion reussie
/// (cahier des charges section 3), depuis les reglages du compte.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _staffMode = false; // false = acheteur (OTP), true = espace pro
  bool _codeSent = false;
  bool _busy = false;
  String? _error;

  final _identifier = TextEditingController();
  final _code = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _identifier.dispose();
    _code.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Une erreur est survenue.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestCode() => _run(() async {
        final id = _identifier.text.trim();
        if (id.isEmpty) {
          setState(() => _error = 'Entrez votre numero ou email.');
          return;
        }
        await ref.read(authControllerProvider.notifier).requestClientCode(id);
        if (mounted) setState(() => _codeSent = true);
      });

  Future<void> _clientLogin() => _run(() async {
        await ref.read(authControllerProvider.notifier).clientLogin(
              identifier: _identifier.text.trim(),
              code: _code.text.trim(),
            );
      });

  Future<void> _staffLogin() => _run(() async {
        await ref.read(authControllerProvider.notifier).login(
              email: _email.text.trim(),
              password: _password.text,
            );
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandLogo(size: 72)),
                  const SizedBox(height: 28),
                  Text(
                    _staffMode ? 'Espace professionnel' : 'Bienvenue',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _staffMode
                        ? 'Connectez-vous avec votre email et mot de passe.'
                        : 'Connectez-vous pour commander en toute simplicite.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 28),
                  if (_error != null) _ErrorBanner(message: _error!),
                  if (_staffMode) ..._staffForm() else ..._clientForm(),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => setState(() {
                              _staffMode = !_staffMode;
                              _error = null;
                              _codeSent = false;
                            }),
                    child: Text(
                      _staffMode
                          ? 'Je suis un acheteur'
                          : 'Espace vendeur / livreur',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _clientForm() {
    return [
      TextField(
        controller: _identifier,
        enabled: !_codeSent,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Numero de telephone ou email',
        ),
      ),
      if (_codeSent) ...[
        const SizedBox(height: 12),
        TextField(
          controller: _code,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Code de verification'),
        ),
      ],
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _busy ? null : (_codeSent ? _clientLogin : _requestCode),
        child: _busy
            ? const _BtnSpinner()
            : Text(_codeSent ? 'Se connecter' : 'Recevoir le code'),
      ),
      if (_codeSent)
        TextButton(
          onPressed: _busy ? null : _requestCode,
          child: const Text('Renvoyer le code'),
        ),
    ];
  }

  List<Widget> _staffForm() {
    return [
      TextField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(labelText: 'Mot de passe'),
      ),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: _busy ? null : _staffLogin,
        child: _busy ? const _BtnSpinner() : const Text('Se connecter'),
      ),
    ];
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.danger, fontSize: 13),
      ),
    );
  }
}

class _BtnSpinner extends StatelessWidget {
  const _BtnSpinner();
  @override
  Widget build(BuildContext context) => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
      );
}
