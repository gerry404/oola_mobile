import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/cart/cart_repository.dart';
import '../../../routing/routes.dart';
import '../../../utils/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: Consumer<CartRepository>(
        builder: (context, cart, _) {
          final favs = cart.favorites;
          if (favs.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              title: 'Aucun favori',
              subtitle: 'Touchez le coeur sur un produit pour l\'ajouter.',
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.64,
            ),
            itemCount: favs.length,
            itemBuilder: (_, i) {
              final f = favs[i];
              return GestureDetector(
                onTap: () => context.push(Routes.productWith(f.slug)),
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
                        child: Stack(fit: StackFit.expand, children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: f.posterUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: f.posterUrl!,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) =>
                                        Container(color: AppColors.grey1),
                                  )
                                : Container(color: AppColors.grey1),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap: () => cart.removeFavorite(f.slug),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.favorite,
                                    color: AppColors.danger, size: 18),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(formatCFA(f.price),
                                style: const TextStyle(
                                    color: AppColors.orange,
                                    fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
