import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../auth/application/auth_controller.dart';
import 'addresses_screen.dart';
import 'favorites_screen.dart';
import 'my_orders_screen.dart';
import 'notifications_screen.dart';
import 'security_screen.dart';

/// Onglet compte : profil resume + acces aux sous-espaces.
class AccountTab extends ConsumerWidget {
  const AccountTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    void go(Widget screen) => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        );

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.orange.withValues(alpha: 0.12),
              child: Text(
                (user?.name.isNotEmpty == true ? user!.name[0] : '?')
                    .toUpperCase(),
                style: const TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Mon compte',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  if (user?.email != null || user?.phone != null)
                    Text(
                      user?.email ?? user?.phone ?? '',
                      style: const TextStyle(color: AppColors.inkSoft),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _MenuItem(
          icon: Icons.receipt_long,
          label: 'Mes commandes',
          onTap: () => go(const MyOrdersScreen()),
        ),
        _MenuItem(
          icon: Icons.place_outlined,
          label: 'Mes adresses',
          onTap: () => go(const AddressesScreen()),
        ),
        _MenuItem(
          icon: Icons.favorite_border,
          label: 'Mes favoris',
          onTap: () => go(const FavoritesScreen()),
        ),
        _MenuItem(
          icon: Icons.notifications_none,
          label: 'Notifications',
          onTap: () => go(const NotificationsScreen()),
        ),
        _MenuItem(
          icon: Icons.fingerprint,
          label: 'Securite et biometrie',
          onTap: () => go(const SecurityScreen()),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).logout(),
          icon: const Icon(Icons.logout, color: AppColors.danger),
          label: const Text('Se deconnecter',
              style: TextStyle(color: AppColors.danger)),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.ink),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right, color: AppColors.inkSoft),
      onTap: onTap,
    );
  }
}
