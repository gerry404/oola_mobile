import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/order.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/vendor_providers.dart';

/// Commandes du vendeur, regroupees par etat.
class VendorOrdersTab extends StatelessWidget {
  const VendorOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.white,
            child: const TabBar(
              labelColor: AppColors.orange,
              unselectedLabelColor: AppColors.inkSoft,
              indicatorColor: AppColors.orange,
              tabs: [
                Tab(text: 'A preparer'),
                Tab(text: 'En livraison'),
                Tab(text: 'Livrees'),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                _OrdersList(group: 'preparing'),
                _OrdersList(group: 'delivering'),
                _OrdersList(group: 'delivered'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrdersList extends ConsumerWidget {
  const _OrdersList({required this.group});
  final String group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vendorOrdersProvider(group));

    return AsyncView(
      value: async,
      onRetry: () => ref.invalidate(vendorOrdersProvider(group)),
      data: (page) {
        if (page.items.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt_long,
            title: 'Aucune commande',
          );
        }
        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async => ref.invalidate(vendorOrdersProvider(group)),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: page.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _VendorOrderCard(
              order: page.items[i],
              canMarkReady: group == 'preparing',
            ),
          ),
        );
      },
    );
  }
}

class _VendorOrderCard extends ConsumerStatefulWidget {
  const _VendorOrderCard({required this.order, required this.canMarkReady});
  final OrderSummary order;
  final bool canMarkReady;

  @override
  ConsumerState<_VendorOrderCard> createState() => _VendorOrderCardState();
}

class _VendorOrderCardState extends ConsumerState<_VendorOrderCard> {
  bool _busy = false;

  Future<void> _markReady() async {
    final id = widget.order.id;
    if (id == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(vendorRepositoryProvider).markOrderReady(id);
      ref.invalidate(vendorOrdersProvider('preparing'));
      if (mounted) showToast(context, 'Commande marquee prete', success: true);
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${o.reference}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(formatCFA(o.totalForShop ?? o.total),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            o.items.map((i) => '${i.quantity}x ${i.title}').join(', '),
            style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text('${o.customerName ?? ""} · ${o.commune ?? ""}',
              style: const TextStyle(color: AppColors.inkSoft, fontSize: 12)),
          if (widget.canMarkReady) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _busy ? null : _markReady,
                icon: _busy
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.check, size: 20),
                label: const Text('Marquer prete'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
