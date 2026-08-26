import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/config/env.dart';
import '../../../shared/models/product_detail.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/price_text.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../cart/application/cart_controller.dart';
import '../../cart/domain/cart_line.dart';
import '../../cart/presentation/checkout_screen.dart';
import '../../favorites/application/favorites_controller.dart';
import '../application/catalog_providers.dart';
import 'widgets/feed_video_player.dart';
import 'widgets/product_reviews.dart';

/// Fiche produit detaillee.
class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({super.key, required this.slug});
  final String slug;

  @override
  ConsumerState<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends ConsumerState<ProductScreen> {
  ProductVariant? _variant;
  bool _muted = true;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(productProvider(widget.slug));

    return Scaffold(
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(productProvider(widget.slug)),
        data: (p) => _content(p),
      ),
      bottomNavigationBar: async.maybeWhen(
        data: (p) => _BuyBar(
          product: p,
          variant: _variant,
          onAddToCart: () => _addToCart(p, buyNow: false),
          onBuyNow: () => _addToCart(p, buyNow: true),
        ),
        orElse: () => null,
      ),
    );
  }

  CartLine _line(ProductDetail p) => CartLine(
        slug: p.slug,
        title: p.title,
        price: p.effectivePrice,
        posterUrl: p.posterUrl,
        shopName: p.shopName,
        variantId: _variant?.id,
        variantLabel: _variant?.label,
      );

  void _addToCart(ProductDetail p, {required bool buyNow}) {
    if (p.hasVariants && _variant == null) {
      showToast(context, 'Choisissez une variante');
      return;
    }
    ref.read(cartControllerProvider.notifier).add(_line(p));
    if (buyNow) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const CheckoutScreen()),
      );
    } else {
      showToast(context, 'Ajoute au panier', success: true);
    }
  }

  Widget _content(ProductDetail p) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 380,
          pinned: true,
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          actions: [
            _FavButton(product: p),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.share(
                '${p.title} sur OOLAshop\n${Env.siteOrigin}/produit/${p.slug}',
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: GestureDetector(
              onTap: () => setState(() => _muted = !_muted),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  FeedVideoPlayer(
                    videoUrl: p.videoUrl,
                    posterUrl: p.posterUrl,
                    isActive: true,
                    muted: _muted,
                  ),
                  if (p.hasVideo)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        height: 38,
                        width: 38,
                        decoration: const BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _muted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(child: _body(p)),
      ],
    );
  }

  Widget _body(ProductDetail p) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (p.shopName != null)
            Row(
              children: [
                const Icon(Icons.storefront, size: 16, color: AppColors.inkSoft),
                const SizedBox(width: 6),
                Text(
                  p.shopName!,
                  style: const TextStyle(
                    color: AppColors.inkSoft,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Text(
            p.title,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              PriceText(
                price: p.effectivePrice,
                original: p.onSale ? p.price : null,
                size: 22,
              ),
              const Spacer(),
              if (p.ratingCount > 0)
                StarRating(value: p.ratingAverage, count: p.ratingCount, size: 15),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (p.conditionLabel.isNotEmpty) _Chip(text: p.conditionLabel),
              if (p.brand != null) _Chip(text: p.brand!),
              if (p.warrantyMonths != null && p.warrantyMonths! > 0)
                _Chip(text: 'Garantie ${p.warrantyMonths} mois'),
              if (p.originCountry != null) _Chip(text: 'Origine ${p.originCountry}'),
            ],
          ),

          if (p.hasVariants) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Choisir une variante'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final v in p.variants)
                  _VariantChip(
                    variant: v,
                    selected: _variant?.id == v.id,
                    onTap: v.inStock
                        ? () => setState(() => _variant = v)
                        : null,
                  ),
              ],
            ),
          ],

          if (p.description != null && p.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Description'),
            const SizedBox(height: 8),
            Text(
              p.description!,
              style: const TextStyle(height: 1.5, color: AppColors.ink),
            ),
          ],

          if (p.attributes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Caracteristiques'),
            const SizedBox(height: 8),
            ...p.attributes.map((a) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 140,
                        child: Text(
                          a.label,
                          style: const TextStyle(color: AppColors.inkSoft),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          a.displayValue,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                )),
          ],

          const SizedBox(height: 24),
          ProductReviews(slug: p.slug),
        ],
      ),
    );
  }
}

class _BuyBar extends StatelessWidget {
  const _BuyBar({
    required this.product,
    required this.variant,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final ProductDetail product;
  final ProductVariant? variant;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.gray100)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onAddToCart,
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: const Text('Panier'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: onBuyNow,
                child: const Text('Acheter maintenant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavButton extends ConsumerWidget {
  const _FavButton({required this.product});
  final ProductDetail product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(favoritesControllerProvider.select(
      (list) => list.any((f) => f.slug == product.slug),
    ));
    return IconButton(
      icon: Icon(isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? AppColors.danger : Colors.white),
      onPressed: () {
        final nowFav = ref.read(favoritesControllerProvider.notifier).toggle(
              FavoriteItem(
                slug: product.slug,
                title: product.title,
                price: product.effectivePrice,
                posterUrl: product.posterUrl,
                shopName: product.shopName,
              ),
            );
        showToast(context, nowFav ? 'Ajoute aux favoris' : 'Retire des favoris');
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}

class _VariantChip extends StatelessWidget {
  const _VariantChip({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  final ProductVariant variant;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.orange : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.gray200,
          ),
        ),
        child: Text(
          disabled ? '${variant.label} (epuise)' : variant.label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (disabled ? AppColors.gray300 : AppColors.ink),
            fontWeight: FontWeight.w600,
            decoration: disabled ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
