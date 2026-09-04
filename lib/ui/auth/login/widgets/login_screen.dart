import 'package:flutter/material.dart';

import '../../../../domain/models/user.dart';
import '../../../../utils/result.dart';
import '../../../core/themes/colors.dart';
import '../../../core/themes/dimens.dart';
import '../../../core/ui/brand_logo.dart';
import '../../../core/ui/state_views.dart';
import '../view_models/login_viewmodel.dart';
import 'otp_field.dart';

enum _Step { email, otp, password }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _staffMode = false;
  _Step _step = _Step.email;
  String _otp = '';

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _staffId = TextEditingController();
  final _staffPassword = TextEditingController();

  LoginViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.requestCode.addListener(_onRequestCode);
    vm.verifyOtp.addListener(_onVerifyOtp);
    vm.biometricLogin.addListener(_onBiometric);
    vm.checkBiometric().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    vm.requestCode.removeListener(_onRequestCode);
    vm.verifyOtp.removeListener(_onVerifyOtp);
    vm.biometricLogin.removeListener(_onBiometric);
    _email.dispose();
    _password.dispose();
    _staffId.dispose();
    _staffPassword.dispose();
    super.dispose();
  }

  void _onBiometric() {
    if (vm.biometricLogin.error) {
      _snack(vm.biometricLogin.result);
      vm.biometricLogin.clearResult();
    }
  }

  void _onRequestCode() {
    if (vm.requestCode.completed) {
      vm.requestCode.clearResult();
      setState(() => _step = _Step.otp);
    } else if (vm.requestCode.error) {
      _snack(vm.requestCode.result);
      vm.requestCode.clearResult();
    }
  }

  void _onVerifyOtp() {
    if (vm.verifyOtp.completed) {
      final res = vm.verifyOtp.result;
      vm.verifyOtp.clearResult();
      if (res is Ok<User> && res.value.role.isPrivileged) {
        // Compte privilegie : mot de passe requis (2FA). Sinon le repository a
        // deja ouvert la session et le router redirige automatiquement.
        setState(() => _step = _Step.password);
      }
    } else if (vm.verifyOtp.error) {
      _snack(vm.verifyOtp.result);
      vm.verifyOtp.clearResult();
    }
  }

  void _snack(Result? result) {
    if (result is Error) {
      showAppSnack(context, describeError(result.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: Dimens.of(context).edgeInsetsScreenSymmetric,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: BrandLogo(size: 72)),
                  const SizedBox(height: 24),
                  Text(_title(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(_subtitle(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.inkSoft)),
                  const SizedBox(height: 28),
                  if (vm.canBiometric && !_staffMode) ...[
                    BiometricButton(onPressed: () => vm.biometricLogin.execute()),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () async {
                        await vm.forgetSession();
                        if (mounted) setState(() => vm.canBiometric = false);
                      },
                      child: const Text('Utiliser un autre compte'),
                    ),
                    const _OrDivider(),
                  ],
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0.05, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Column(
                      key: ValueKey('$_staffMode$_step'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _staffMode ? _staffForm() : _clientForm(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_staffMode || _step == _Step.email)
                    TextButton(
                      onPressed: () => setState(() {
                        _staffMode = !_staffMode;
                        _step = _Step.email;
                      }),
                      child: Text(_staffMode
                          ? 'Je suis un acheteur'
                          : 'Espace vendeur / livreur'),
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
      _Step.email => 'Bienvenue',
      _Step.otp => 'Code de verification',
      _Step.password => 'Verification requise',
    };
  }

  String _subtitle() {
    if (_staffMode) return 'Connectez-vous avec votre email et mot de passe.';
    return switch (_step) {
      _Step.email => 'Connectez-vous pour commander en toute simplicite.',
      _Step.otp => 'Entrez le code envoye a ${_email.text.trim()}.',
      _Step.password => 'Ce compte a des privileges : confirmez votre mot de passe.',
    };
  }

  List<Widget> _clientForm() {
    switch (_step) {
      case _Step.email:
        return [
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Adresse email'),
          ),
          const SizedBox(height: 20),
          _submit(vm.requestCode, 'Recevoir le code',
              () => vm.requestCode.execute(_email.text.trim())),
        ];
      case _Step.otp:
        return [
          OtpField(
            onChanged: (v) => _otp = v,
            onCompleted: (v) => vm.verifyOtp.execute((_email.text.trim(), v)),
          ),
          const SizedBox(height: 20),
          _submit(vm.verifyOtp, 'Se connecter',
              () => vm.verifyOtp.execute((_email.text.trim(), _otp))),
          TextButton(
            onPressed: () => vm.requestCode.execute(_email.text.trim()),
            child: const Text('Renvoyer le code'),
          ),
          TextButton(
            onPressed: () => setState(() => _step = _Step.email),
            child: const Text("Modifier l'email"),
          ),
        ];
      case _Step.password:
        return [
          TextField(
            controller: _password,
            obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Mot de passe'),
          ),
          const SizedBox(height: 20),
          _submit(vm.completePassword, 'Confirmer',
              () => vm.completePassword
                  .execute((_email.text.trim(), _password.text))),
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
      ),
      const SizedBox(height: 20),
      _submit(vm.passwordLogin, 'Se connecter',
          () => vm.passwordLogin
              .execute((_staffId.text.trim(), _staffPassword.text))),
    ];
  }

  Widget _submit(dynamic command, String label, VoidCallback onPressed) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, _) {
        final busy = command.running as bool;
        // Affiche les erreurs du login pro / mot de passe.
        if (command.error == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _snack(command.result as Result?);
            command.clearResult();
          });
        }
        return ElevatedButton(
          onPressed: busy ? null : onPressed,
          child: busy
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.2, color: Colors.white))
              : Text(label),
        );
      },
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(child: Divider(color: AppColors.grey2)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('ou', style: TextStyle(color: AppColors.inkSoft)),
            ),
            Expanded(child: Divider(color: AppColors.grey2)),
          ],
        ),
      );
}
