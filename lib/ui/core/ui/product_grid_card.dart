import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/product.dart';
import '../../../routing/routes.dart';
import '../../../utils/formatters.dart';
import '../themes/colors.dart';

/// Carte produit en grille (recherche, favoris).
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({super.key, required this.product});
  final ProductCard product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.productWith(product.slug)),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(14)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (product.posterUrl != null)
                      CachedNetworkImage(
                        imageUrl: product.posterUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: AppColors.grey1),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.grey1),
                      )
                    else
                      Container(color: AppColors.grey1),
                    if (product.hasVideo)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 22),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600, height: 1.2)),
                  const SizedBox(height: 6),
                  Text(formatCFA(product.effectivePrice),
                      style: const TextStyle(
                          color: AppColors.orange, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
