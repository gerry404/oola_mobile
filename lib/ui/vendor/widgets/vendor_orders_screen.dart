import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/vendor/vendor_repository.dart';
import '../../../domain/models/order.dart';
import '../../../utils/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/vendor_orders_viewmodel.dart';

/// Commandes vendeur, regroupees par etat (dont annulees / retours).
class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  static const _groups = ['preparing', 'delivering', 'delivered', 'cancelled'];
  static const _labels = [
    'A preparer',
    'En livraison',
    'Livrees',
    'Annulees / Retours'
  ];

  late final List<VendorOrdersViewModel> _vms;

  @override
  void initState() {
    super.initState();
    final repo = context.read<VendorRepository>();
    _vms = _groups
        .map((g) => VendorOrdersViewModel(vendorRepository: repo, group: g))
        .toList();
  }

  @override
  void dispose() {
    for (final vm in _vms) {
      vm.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _groups.length,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.orange,
              unselectedLabelColor: AppColors.inkSoft,
              indicatorColor: AppColors.orange,
              tabs: [for (final l in _labels) Tab(text: l)],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                for (final vm in _vms)
                  _OrdersList(vm: vm, canMarkReady: vm.group == 'preparing'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  const _OrdersList({required this.vm, required this.canMarkReady});
  final VendorOrdersViewModel vm;
  final bool canMarkReady;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([vm, vm.load]),
      builder: (context, _) {
        if (vm.load.running && vm.items.isEmpty) return const LoadingIndicator();
        if (vm.items.isEmpty) {
          return const EmptyState(
              icon: Icons.receipt_long, title: 'Aucune commande');
        }
        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () => vm.load.execute(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vm.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _OrderCard(
              order: vm.items[i],
              canMarkReady: canMarkReady,
              onMarkReady: () {
                final id = vm.items[i].id;
                if (id != null) vm.markReady.execute(id);
              },
            ),
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard(
      {required this.order,
      required this.canMarkReady,
      required this.onMarkReady});
  final OrderSummary order;
  final bool canMarkReady;
  final VoidCallback onMarkReady;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('#${order.reference}',
                style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            if (order.status.isTerminalBad)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(7)),
                child: Text(order.status.label,
                    style: const TextStyle(
                        color: AppColors.danger,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
            const Spacer(),
            Text(formatCFA(order.totalForShop ?? order.total),
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 6),
          Text(order.items.map((i) => '${i.quantity}x ${i.title}').join(', '),
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
          const SizedBox(height: 4),
          Text('${order.customerName ?? ""} · ${order.commune ?? ""}',
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 12)),
          if (canMarkReady) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onMarkReady,
                icon: const Icon(Icons.check, size: 20),
                label: const Text('Marquer prete'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
