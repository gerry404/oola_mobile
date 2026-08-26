import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/vendor_providers.dart';
import '../domain/vendor_models.dart';
import 'add_product_screen.dart';

/// Catalogue du vendeur.
class VendorProductsTab extends ConsumerWidget {
  const VendorProductsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(vendorProductsProvider);

    return Scaffold(
      backgroundColor: AppColors.cream,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (created == true) ref.invalidate(vendorProductsProvider);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(vendorProductsProvider),
        data: (page) {
          if (page.items.isEmpty) {
            return const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Aucun produit',
              subtitle: 'Ajoutez votre premier produit avec sa video.',
            );
          }
          return RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () async => ref.invalidate(vendorProductsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: page.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _ProductTile(product: page.items[i]),
            ),
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product});
  final VendorProduct product;

  Color get _statusColor => switch (product.status) {
        'approved' => AppColors.mint,
        'pending' => AppColors.warning,
        'rejected' => AppColors.danger,
        _ => AppColors.inkSoft,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
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
                          Container(color: AppColors.gray100),
                    )
                  : Container(
                      color: AppColors.gray100,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.gray300),
                    ),
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(product.statusLabel,
                          style: TextStyle(
                              color: _statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    ),
                    if (product.hasVideo) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.play_circle_fill,
                          size: 16, color: AppColors.orange),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
