import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../routing/routes.dart';
import '../../core/themes/colors.dart';

/// Onglet compte : profil resume + acces aux sous-espaces.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
      builder: (context, auth, _) {
        final user = auth.currentUser;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.orange.withValues(alpha: 0.12),
                child: Text(
                  (user?.name.isNotEmpty == true ? user!.name[0] : '?')
                      .toUpperCase(),
                  style: const TextStyle(
                      color: AppColors.orange,
                      fontWeight: FontWeight.w800,
                      fontSize: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Mon compte',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    if (user?.email != null || user?.phone != null)
                      Text(user?.email ?? user?.phone ?? '',
                          style: const TextStyle(color: AppColors.inkSoft)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 28),
            _MenuItem(
                icon: Icons.receipt_long,
                label: 'Mes commandes',
                onTap: () => context.push(Routes.orders)),
            _MenuItem(
                icon: Icons.place_outlined,
                label: 'Mes adresses',
                onTap: () => context.push(Routes.addresses)),
            _MenuItem(
                icon: Icons.favorite_border,
                label: 'Mes favoris',
                onTap: () => context.push(Routes.favorites)),
            _MenuItem(
                icon: Icons.notifications_none,
                label: 'Notifications',
                onTap: () => context.push(Routes.notifications)),
            _MenuItem(
                icon: Icons.fingerprint,
                label: 'Securite et biometrie',
                onTap: () => context.push(Routes.security)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => auth.logout(),
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Se deconnecter',
                  style: TextStyle(color: AppColors.danger)),
            ),
          ],
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem(
      {required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.ink),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppColors.inkSoft),
        onTap: onTap,
      );
}
