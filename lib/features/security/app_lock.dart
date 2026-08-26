import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/auth/biometric_service.dart';
import '../../core/providers.dart';
import '../../shared/widgets/brand_logo.dart';
import '../auth/application/auth_controller.dart';

/// Verrou biometrique a l'ouverture de l'application (cahier des charges §3.1).
///
/// Quand la biometrie est activee et l'utilisateur connecte, l'app est
/// verrouillee au lancement et re-verrouillee quand elle repasse en arriere-plan.
/// Le deverrouillage se fait d'un simple contact (empreinte / visage).
class AppLock extends ConsumerStatefulWidget {
  const AppLock({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AppLock> createState() => _AppLockState();
}

class _AppLockState extends ConsumerState<AppLock>
    with WidgetsBindingObserver {
  bool _biometricEnabled = false;
  bool _unlocked = true;
  bool _checked = false;
  bool _prompting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _check() async {
    final enabled = await ref.read(secureStoreProvider).isBiometricEnabled();
    if (!mounted) return;
    setState(() {
      _biometricEnabled = enabled;
      _unlocked = !enabled; // verrouille si active
      _checked = true;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-verrouille des que l'app passe en arriere-plan.
    if (state == AppLifecycleState.paused && _biometricEnabled) {
      setState(() => _unlocked = false);
    }
  }

  Future<void> _unlock() async {
    if (_prompting) return;
    _prompting = true;
    final res = await ref
        .read(biometricProvider)
        .authenticate(reason: 'Deverrouillez OOLAshop');
    _prompting = false;
    if (!mounted) return;
    if (res == BiometricResult.success ||
        res == BiometricResult.unavailable ||
        res == BiometricResult.notEnrolled) {
      setState(() => _unlocked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authed = ref.watch(authControllerProvider).isAuthenticated;
    final shouldLock = _checked && authed && _biometricEnabled && !_unlocked;

    return Stack(
      children: [
        widget.child,
        if (shouldLock) _LockScreen(onUnlock: _unlock),
      ],
    );
  }
}

class _LockScreen extends StatefulWidget {
  const _LockScreen({required this.onUnlock});
  final VoidCallback onUnlock;

  @override
  State<_LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<_LockScreen> {
  @override
  void initState() {
    super.initState();
    // Declenche automatiquement la demande a l'affichage.
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.onUnlock());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cream,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(size: 76),
            const SizedBox(height: 28),
            const Icon(Icons.lock_outline, size: 32, color: AppColors.inkSoft),
            const SizedBox(height: 12),
            const Text('Application verrouillee',
                style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: widget.onUnlock,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Deverrouiller'),
            ),
          ],
        ),
      ),
    );
  }
}
