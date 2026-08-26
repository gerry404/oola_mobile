import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/providers.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../auth/application/auth_controller.dart';
import '../application/account_providers.dart';

/// Reglages de securite : biometrie, mot de passe, suppression de compte.
class SecurityScreen extends ConsumerStatefulWidget {
  const SecurityScreen({super.key});

  @override
  ConsumerState<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends ConsumerState<SecurityScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = ref.read(secureStoreProvider);
    final service = ref.read(biometricProvider);
    final enabled = await store.isBiometricEnabled();
    final available = await service.isAvailable && await service.hasEnrolled;
    if (mounted) {
      setState(() {
        _biometricEnabled = enabled;
        _biometricAvailable = available;
        _loading = false;
      });
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    final store = ref.read(secureStoreProvider);
    if (value) {
      // Confirme par une authentification avant d'activer.
      final res = await ref.read(biometricProvider).authenticate(
            reason: 'Activez la connexion biometrique',
          );
      if (res != BiometricResult.success) {
        if (mounted) showToast(context, 'Activation annulee.');
        return;
      }
    }
    await store.setBiometricEnabled(value);
    if (mounted) {
      setState(() => _biometricEnabled = value);
      showToast(context,
          value ? 'Biometrie activee' : 'Biometrie desactivee',
          success: value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Securite')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.orange))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gray100),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.fingerprint,
                          color: AppColors.orange, size: 30),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Connexion biometrique',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              'Empreinte ou visage pour ouvrir l\'app et confirmer les paiements.',
                              style: TextStyle(
                                  color: AppColors.inkSoft, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        activeThumbColor: AppColors.orange,
                        value: _biometricEnabled,
                        onChanged: _biometricAvailable ? _toggleBiometric : null,
                      ),
                    ],
                  ),
                ),
                if (!_biometricAvailable)
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'Aucune empreinte / visage enregistre sur cet appareil.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                _ActionTile(
                  icon: Icons.lock_outline,
                  label: 'Changer le mot de passe',
                  onTap: () => _changePassword(context),
                ),
                _ActionTile(
                  icon: Icons.delete_outline,
                  label: 'Supprimer mon compte',
                  danger: true,
                  onTap: () => _deleteAccount(context),
                ),
              ],
            ),
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    // Operation sensible : re-verification biometrique.
    final ok = await ref
        .read(biometricProvider)
        .authenticate(reason: 'Confirmez pour changer le mot de passe');
    if (ok != BiometricResult.success &&
        ok != BiometricResult.unavailable &&
        ok != BiometricResult.notEnrolled) {
      return;
    }
    if (!context.mounted) return;

    final current = TextEditingController();
    final next = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Changer le mot de passe'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: current,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Mot de passe actuel'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: next,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Nouveau mot de passe'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Valider')),
        ],
      ),
    );

    if (result == true) {
      try {
        await ref.read(accountRepositoryProvider).updatePassword(
              current: current.text,
              password: next.text,
            );
        if (context.mounted) {
          showToast(context, 'Mot de passe mis a jour', success: true);
        }
      } on ApiException catch (e) {
        if (context.mounted) showToast(context, e.message);
      }
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
            'Cette action est definitive. Voulez-vous vraiment supprimer votre compte ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    // Operation sensible : re-verification biometrique.
    final ok = await ref
        .read(biometricProvider)
        .authenticate(reason: 'Confirmez la suppression du compte');
    if (ok == BiometricResult.failed || ok == BiometricResult.canceled) return;

    // La suppression effective peut etre branchee sur DELETE /me ;
    // ici on deconnecte au minimum.
    await ref.read(authControllerProvider.notifier).logout();
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.ink;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.inkSoft),
      onTap: onTap,
    );
  }
}
