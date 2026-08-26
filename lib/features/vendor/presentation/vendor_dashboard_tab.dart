import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/vendor_providers.dart';
import '../domain/vendor_models.dart';

/// Tableau de bord vendeur : ventes, commandes, catalogue, solde.
class VendorDashboardTab extends ConsumerWidget {
  const VendorDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vendorDashboardProvider);

    return AsyncView(
      value: async,
      onRetry: () => ref.invalidate(vendorDashboardProvider),
      data: (d) => RefreshIndicator(
        color: AppColors.orange,
        onRefresh: () async => ref.invalidate(vendorDashboardProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ShopHeader(dashboard: d),
            const SizedBox(height: 16),
            _RevenueCard(dashboard: d),
            const SizedBox(height: 16),
            const _SectionTitle('Commandes'),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatBox(
                  label: 'A preparer',
                  value: '${d.ordersPreparing}',
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  label: 'En livraison',
                  value: '${d.ordersDelivering}',
                  color: AppColors.orange,
                ),
                const SizedBox(width: 10),
                _StatBox(
                  label: 'Livrees',
                  value: '${d.ordersDelivered}',
                  color: AppColors.mint,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const _SectionTitle('Catalogue'),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatBox(
                    label: 'En ligne',
                    value: '${d.productsApproved}',
                    color: AppColors.mint),
                const SizedBox(width: 10),
                _StatBox(
                    label: 'En validation',
                    value: '${d.productsPending}',
                    color: AppColors.warning),
                const SizedBox(width: 10),
                _StatBox(
                    label: 'Brouillons',
                    value: '${d.productsDraft}',
                    color: AppColors.inkSoft),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.dashboard});
  final VendorDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.orange.withValues(alpha: 0.12),
            backgroundImage: dashboard.logoUrl != null
                ? NetworkImage(dashboard.logoUrl!)
                : null,
            child: dashboard.logoUrl == null
                ? const Icon(Icons.storefront, color: AppColors.orange)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(dashboard.shopName,
                          style: const TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800)),
                    ),
                    if (dashboard.isCertified) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          size: 18, color: AppColors.mint),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                if (!dashboard.kycValidated)
                  const Text('Documents a valider (KYC)',
                      style: TextStyle(color: AppColors.warning, fontSize: 12))
                else
                  const Text('Boutique verifiee',
                      style: TextStyle(color: AppColors.mint, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.dashboard});
  final VendorDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solde disponible',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(formatCFA(dashboard.availableBalance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Row(
            children: [
              _rev('Aujourd\'hui', dashboard.revenueToday),
              _rev('Semaine', dashboard.revenueWeek),
              _rev('Mois', dashboard.revenueMonth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rev(String label, int value) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white54, fontSize: 11)),
            const SizedBox(height: 2),
            Text(formatCFACompact(value),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
}
