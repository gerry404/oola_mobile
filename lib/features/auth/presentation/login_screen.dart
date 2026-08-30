import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../application/auth_controller.dart';
import 'widgets/otp_input.dart';

/// Etapes du parcours de connexion acheteur.
enum _ClientStep { email, otp, password }

/// Connexion.
///  - Acheteur : email -> code OTP -> (mot de passe si compte privilegie).
///  - Espace pro (vendeur / livreur / admin) : email ou telephone + mot de passe.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _staffMode = false;
  _ClientStep _step = _ClientStep.email;
  bool _busy = false;
  String? _error;
  String _otp = '';

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _staffId = TextEditingController();
  final _staffPassword = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _staffId.dispose();
    _staffPassword.dispose();
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

  // ---- Acheteur ----
  Future<void> _requestCode() => _run(() async {
        final email = _email.text.trim();
        if (email.isEmpty) {
          setState(() => _error = 'Entrez votre adresse email.');
          return;
        }
        await ref.read(authControllerProvider.notifier).requestClientCode(email);
        if (mounted) setState(() => _step = _ClientStep.otp);
      });

  Future<void> _verifyOtp(String code) => _run(() async {
        final outcome = await ref
            .read(authControllerProvider.notifier)
            .clientLogin(email: _email.text.trim(), code: code);
        // Compte privilegie : on demande le mot de passe (double facteur).
        if (outcome == ClientLoginOutcome.passwordRequired && mounted) {
          setState(() => _step = _ClientStep.password);
        }
      });

  Future<void> _completePrivileged() => _run(() async {
        await ref.read(authControllerProvider.notifier).completePrivilegedLogin(
              email: _email.text.trim(),
              password: _password.text,
            );
      });

  // ---- Pro ----
  Future<void> _staffLogin() => _run(() async {
        await ref.read(authControllerProvider.notifier).login(
              identifier: _staffId.text.trim(),
              password: _staffPassword.text,
            );
      });

  void _resetClient() => setState(() {
        _step = _ClientStep.email;
        _otp = '';
        _password.clear();
        _error = null;
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
                    _title(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitle(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.inkSoft),
                  ),
                  const SizedBox(height: 28),
                  if (_error != null) _ErrorBanner(message: _error!),
                  // Animation douce entre les etapes.
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.06, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey('${_staffMode}_$_step'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _staffMode ? _staffForm() : _clientForm(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (!(_staffMode == false && _step != _ClientStep.email))
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                                _staffMode = !_staffMode;
                                _resetClient();
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

  String _title() {
    if (_staffMode) return 'Espace professionnel';
    return switch (_step) {
      _ClientStep.email => 'Bienvenue',
      _ClientStep.otp => 'Code de verification',
      _ClientStep.password => 'Verification requise',
    };
  }

  String _subtitle() {
    if (_staffMode) {
      return 'Connectez-vous avec votre email et mot de passe.';
    }
    return switch (_step) {
      _ClientStep.email =>
        'Connectez-vous pour commander en toute simplicite.',
      _ClientStep.otp => 'Entrez le code envoye a ${_email.text.trim()}.',
      _ClientStep.password =>
        'Ce compte a des privileges : confirmez votre mot de passe.',
    };
  }

  List<Widget> _clientForm() {
    switch (_step) {
      case _ClientStep.email:
        return [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Adresse email'),
            onSubmitted: (_) => _requestCode(),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            busy: _busy,
            label: 'Recevoir le code',
            onPressed: _requestCode,
          ),
        ];

      case _ClientStep.otp:
        return [
          OtpInput(
            enabled: !_busy,
            hasError: _error != null,
            onChanged: (v) => _otp = v,
            onCompleted: _verifyOtp,
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            busy: _busy,
            label: 'Se connecter',
            onPressed: () => _verifyOtp(_otp),
          ),
          TextButton(
            onPressed: _busy ? null : _requestCode,
            child: const Text('Renvoyer le code'),
          ),
          TextButton(
            onPressed: _busy ? null : _resetClient,
            child: const Text('Modifier l\'email'),
          ),
        ];

      case _ClientStep.password:
        return [
          TextField(
            controller: _password,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Mot de passe'),
            onSubmitted: (_) => _completePrivileged(),
          ),
          const SizedBox(height: 20),
          _PrimaryButton(
            busy: _busy,
            label: 'Confirmer',
            onPressed: _completePrivileged,
          ),
        ];
    }
  }

  List<Widget> _staffForm() {
    return [
      TextField(
        controller: _staffId,
        keyboardType: TextInputType.emailAddress,
        autofillHints: const [AutofillHints.username],
        decoration: const InputDecoration(labelText: 'Email ou telephone'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _staffPassword,
        obscureText: true,
        autofillHints: const [AutofillHints.password],
        decoration: const InputDecoration(labelText: 'Mot de passe'),
        onSubmitted: (_) => _staffLogin(),
      ),
      const SizedBox(height: 20),
      _PrimaryButton(busy: _busy, label: 'Se connecter', onPressed: _staffLogin),
    ];
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.busy,
    required this.label,
    required this.onPressed,
  });

  final bool busy;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: busy ? null : onPressed,
      child: busy
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2.2, color: Colors.white),
            )
          : Text(label),
    );
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
