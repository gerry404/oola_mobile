import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/vendor.dart';
import '../../../routing/routes.dart';
import '../../../utils/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/vendor_products_viewmodel.dart';

class VendorProductsScreen extends StatelessWidget {
  const VendorProductsScreen({super.key, required this.viewModel});

  final VendorProductsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        onPressed: () async {
          final created = await context.push<bool>(Routes.addProduct);
          if (created == true) viewModel.load.execute();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.load]),
        builder: (context, _) {
          if (viewModel.load.running && viewModel.items.isEmpty) {
            return const LoadingIndicator();
          }
          if (viewModel.items.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Aucun produit',
              subtitle: 'Ajoutez votre premier produit avec sa video.',
            );
          }
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () => viewModel.load.execute(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ProductTile(
                product: viewModel.items[i],
                onSubmit: () => viewModel.submit.execute(viewModel.items[i].id),
                onDelete: () => viewModel.remove.execute(viewModel.items[i].id),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile(
      {required this.product, required this.onSubmit, required this.onDelete});
  final VendorProduct product;
  final VoidCallback onSubmit;
  final VoidCallback onDelete;

  Color get _statusColor => switch (product.status) {
        'approved' => AppColors.mint,
        'pending' => AppColors.warning,
        'rejected' => AppColors.danger,
        _ => AppColors.inkSoft,
      };

  @override
  Widget build(BuildContext context) {
    final canSubmit = product.status == 'draft' || product.status == 'rejected';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                height: 60,
                width: 60,
                child: product.posterUrl != null
                    ? CachedNetworkImage(
                        imageUrl: product.posterUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.grey1))
                    : Container(
                        color: AppColors.grey1,
                        child: const Icon(Icons.image_outlined,
                            color: AppColors.grey3)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text('${formatCFA(product.price)} · stock ${product.stock}',
                      style: const TextStyle(
                          color: AppColors.inkSoft, fontSize: 13)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(product.statusLabel,
                        style: TextStyle(
                            color: _statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ]),
          if (product.status == 'rejected') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Raison du refus',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    product.rejectionReason?.trim().isNotEmpty == true
                        ? product.rejectionReason!
                        : 'Verifiez que la video et les informations respectent nos regles.',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          if (product.status != 'approved') ...[
            const SizedBox(height: 10),
            Row(children: [
              if (canSubmit)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onSubmit,
                    icon: const Icon(Icons.send, size: 18),
                    label: Text(product.status == 'rejected'
                        ? 'Renvoyer'
                        : 'Soumettre'),
                  ),
                ),
              if (canSubmit) const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onDelete,
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger)),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Supprimer'),
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
