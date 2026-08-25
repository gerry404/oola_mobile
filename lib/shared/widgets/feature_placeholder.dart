import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Ecran d'attente pour les modules en cours de construction.
/// Sert de jalon visuel pendant la mise en place du socle.
class FeaturePlaceholder extends StatelessWidget {
  const FeaturePlaceholder({
    super.key,
    required this.title,
    required this.icon,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: 72,
              decoration: BoxDecoration(
                color: AppColors.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: AppColors.orange, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle ?? 'Module en cours de construction',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
