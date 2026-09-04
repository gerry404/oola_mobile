import 'package:flutter/material.dart';

import '../../../domain/models/vendor.dart';
import '../../../utils/formatters.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/vendor_dashboard_viewmodel.dart';

class VendorDashboardScreen extends StatelessWidget {
  const VendorDashboardScreen({super.key, required this.viewModel});

  final VendorDashboardViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.load]),
      builder: (context, _) {
        final d = viewModel.dashboard;
        if (viewModel.load.running && d == null) return const LoadingIndicator();
        if (d == null) {
          final e = viewModel.load.result;
          return ErrorIndicator(
            message: e is Error ? describeError(e.error) : 'Erreur.',
            onRetry: () => viewModel.load.execute(),
          );
        }
        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () => viewModel.load.execute(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _ShopHeader(d: d),
              const SizedBox(height: 16),
              _RevenueCard(d: d),
              const SizedBox(height: 16),
              const _Title('Commandes'),
              const SizedBox(height: 8),
              Row(children: [
                _Stat('A preparer', '${d.ordersPreparing}', AppColors.warning),
                const SizedBox(width: 10),
                _Stat('En livraison', '${d.ordersDelivering}', AppColors.orange),
                const SizedBox(width: 10),
                _Stat('Livrees', '${d.ordersDelivered}', AppColors.mint),
              ]),
              const SizedBox(height: 16),
              const _Title('Catalogue'),
              const SizedBox(height: 8),
              Row(children: [
                _Stat('En ligne', '${d.productsApproved}', AppColors.mint),
                const SizedBox(width: 10),
                _Stat('En validation', '${d.productsPending}', AppColors.warning),
                const SizedBox(width: 10),
                _Stat('Brouillons', '${d.productsDraft}', AppColors.inkSoft),
              ]),
            ],
          ),
        );
      },
    );
  }
}

class _ShopHeader extends StatelessWidget {
  const _ShopHeader({required this.d});
  final VendorDashboard d;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: AppColors.orange.withValues(alpha: 0.12),
          backgroundImage:
              d.logoUrl != null ? NetworkImage(d.logoUrl!) : null,
          child: d.logoUrl == null
              ? const Icon(Icons.storefront, color: AppColors.orange)
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Flexible(
                    child: Text(d.shopName,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w800))),
                if (d.isCertified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, size: 18, color: AppColors.mint),
                ],
              ]),
              const SizedBox(height: 2),
              Text(d.kycValidated ? 'Boutique verifiee' : 'Documents a valider (KYC)',
                  style: TextStyle(
                      color: d.kycValidated ? AppColors.mint : AppColors.warning,
                      fontSize: 12)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  const _RevenueCard({required this.d});
  final VendorDashboard d;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: AppColors.ink, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solde disponible',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(formatCFA(d.availableBalance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 16),
          Row(children: [
            _rev("Aujourd'hui", d.revenueToday),
            _rev('Semaine', d.revenueWeek),
            _rev('Mois', d.revenueMonth),
          ]),
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

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey1),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.w900, color: color)),
          const SizedBox(height: 4),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.inkSoft)),
        ]),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
}
