import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/order.dart';
import '../../../routing/routes.dart';
import '../../../utils/formatters.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/my_orders_viewmodel.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key, required this.viewModel});

  final MyOrdersViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.load]),
        builder: (context, _) {
          if (viewModel.load.running && viewModel.items.isEmpty) {
            return const LoadingIndicator();
          }
          if (viewModel.load.error && viewModel.items.isEmpty) {
            final e = viewModel.load.result;
            return ErrorIndicator(
              message: e is Error ? describeError(e.error) : 'Erreur.',
              onRetry: () => viewModel.load.execute(),
            );
          }
          if (viewModel.items.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt_long,
              title: 'Aucune commande',
              subtitle: 'Vos achats apparaitront ici.',
            );
          }
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () => viewModel.load.execute(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _OrderTile(order: viewModel.items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final OrderSummary order;

  @override
  Widget build(BuildContext context) {
    final color = switch (order.status) {
      OrderStatus.delivered => AppColors.mint,
      _ when order.status.isTerminalBad => AppColors.danger,
      _ => AppColors.warning,
    };
    return GestureDetector(
      onTap: () => context.push(Routes.orderWith(order.reference)),
      child: Container(
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
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(order.status.label,
                    style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(order.items.map((i) => '${i.quantity}x ${i.title}').join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
            const SizedBox(height: 10),
            Row(children: [
              if (order.createdAt != null)
                Text(formatDateFr(order.createdAt!),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.inkSoft)),
              const Spacer(),
              Text(formatCFA(order.total),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 15)),
            ]),
          ],
        ),
      ),
    );
  }
}
