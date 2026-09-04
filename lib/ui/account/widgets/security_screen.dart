import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/services/biometric_service.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';

/// Reglages de securite : activation de la biometrie.
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _enabled = false;
  bool _available = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final auth = context.read<AuthRepository>();
    final bio = context.read<BiometricService>();
    final enabled = await auth.isBiometricEnabled();
    final available = await bio.isAvailable && await bio.hasEnrolled;
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _available = available;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    final auth = context.read<AuthRepository>();
    final bio = context.read<BiometricService>();
    if (value) {
      final res = await bio.authenticate(reason: 'Activez la connexion biometrique');
      if (res != BiometricResult.success) {
        if (mounted) showAppSnack(context, 'Activation annulee.');
        return;
      }
    }
    await auth.setBiometricEnabled(value);
    if (mounted) {
      setState(() => _enabled = value);
      showAppSnack(context, value ? 'Biometrie activee' : 'Biometrie desactivee',
          success: value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Securite')),
      body: _loading
          ? const LoadingIndicator()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.grey1),
                  ),
                  child: Row(children: [
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
                      value: _enabled,
                      onChanged: _available ? _toggle : null,
                    ),
                  ]),
                ),
                if (!_available)
                  const Padding(
                    padding: EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      'Aucune empreinte / visage enregistre sur cet appareil.',
                      style: TextStyle(color: AppColors.inkSoft, fontSize: 12),
                    ),
                  ),
              ],
            ),
    );
  }
}
