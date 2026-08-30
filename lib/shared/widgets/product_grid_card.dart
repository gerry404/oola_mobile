import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/navigation/app_transitions.dart';
import '../../app/theme/app_colors.dart';
import '../../features/catalog/presentation/product_screen.dart';
import '../models/product_card.dart';
import 'price_text.dart';

/// Carte produit en grille (recherche, favoris, rails).
class ProductGridCard extends StatelessWidget {
  const ProductGridCard({super.key, required this.product});
  final ProductCard product;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        AppTransitions.modalRoute(ProductScreen(slug: product.slug)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray100),
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
                            Container(color: AppColors.gray100),
                        errorWidget: (_, __, ___) =>
                            Container(color: AppColors.gray100),
                      )
                    else
                      Container(color: AppColors.gray100),
                    if (product.hasVideo)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: Icon(Icons.play_circle_fill,
                            color: Colors.white, size: 22),
                      ),
                    if (product.onSale)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.danger,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('PROMO',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800)),
                        ),
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
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  PriceText(
                    price: product.effectivePrice,
                    original: product.onSale ? product.price : null,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
