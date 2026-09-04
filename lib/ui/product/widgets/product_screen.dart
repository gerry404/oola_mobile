import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../config/env.dart';
import '../../../data/repositories/cart/cart_repository.dart';
import '../../../domain/models/cart_line.dart';
import '../../../domain/models/product.dart';
import '../../../routing/routes.dart';
import '../../../utils/formatters.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/star_rating.dart';
import '../../core/ui/state_views.dart';
import '../../feed/widgets/feed_video_player.dart';
import '../view_models/product_viewmodel.dart';
import 'product_reviews.dart';

/// Fiche produit detaillee.
class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.viewModel});

  final ProductViewModel viewModel;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  ProductVariant? _variant;
  bool _muted = true;

  ProductViewModel get vm => widget.viewModel;

  void _addToCart(ProductDetail p, {required bool buyNow}) {
    if (p.hasVariants && _variant == null) {
      showAppSnack(context, 'Choisissez une variante');
      return;
    }
    context.read<CartRepository>().addToCart(CartLine(
          slug: p.slug,
          title: p.title,
          price: p.effectivePrice,
          posterUrl: p.posterUrl,
          shopName: p.shopName,
          variantId: _variant?.id,
          variantLabel: _variant?.label,
        ));
    if (buyNow) {
      context.push(Routes.checkout);
    } else {
      showAppSnack(context, 'Ajoute au panier', success: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: Listenable.merge([vm, vm.load]),
        builder: (context, _) {
          final p = vm.product;
          if (vm.load.running && p == null) {
            return const Scaffold(body: LoadingIndicator());
          }
          if (p == null) {
            final err = vm.load.result;
            return ErrorIndicator(
              message: err is Error ? describeError(err.error) : 'Erreur.',
              onRetry: () => vm.load.execute(),
            );
          }
          return _content(p);
        },
      ),
      bottomNavigationBar: vm.product == null ? null : _buyBar(vm.product!),
    );
  }

  Widget _buyBar(ProductDetail p) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(top: BorderSide(color: AppColors.grey1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addToCart(p, buyNow: false),
                icon: const Icon(Icons.add_shopping_cart, size: 20),
                label: const Text('Panier'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _addToCart(p, buyNow: true),
                child: const Text('Acheter maintenant'),
              ),
            ),
          ],
        ),
      ),
    );
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
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => Share.share(
                  '${p.title} sur OOLAshop\n${Env.siteOrigin}/produit/${p.slug}'),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: GestureDetector(
              onTap: () => setState(() => _muted = !_muted),
              child: FeedVideoPlayer(
                videoUrl: p.videoUrl,
                posterUrl: p.posterUrl,
                isActive: true,
                muted: _muted,
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
            Row(children: [
              const Icon(Icons.storefront, size: 16, color: AppColors.inkSoft),
              const SizedBox(width: 6),
              Text(p.shopName!,
                  style: const TextStyle(
                      color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
            ]),
          const SizedBox(height: 8),
          Text(p.title,
              style: const TextStyle(
                  fontSize: 21, fontWeight: FontWeight.w800, height: 1.25)),
          const SizedBox(height: 10),
          Row(children: [
            Text(formatCFA(p.effectivePrice),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange)),
            if (p.onSale) ...[
              const SizedBox(width: 8),
              Text(formatCFA(p.price),
                  style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: AppColors.inkSoft)),
            ],
            const Spacer(),
            if (p.ratingCount > 0)
              StarRating(value: p.ratingAverage, count: p.ratingCount, size: 15),
          ]),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            if (p.conditionLabel.isNotEmpty) _Chip(text: p.conditionLabel),
            if (p.brand != null) _Chip(text: p.brand!),
            if (p.warrantyMonths != null && p.warrantyMonths! > 0)
              _Chip(text: 'Garantie ${p.warrantyMonths} mois'),
          ]),
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
                    onTap: v.inStock ? () => setState(() => _variant = v) : null,
                  ),
              ],
            ),
          ],
          if (p.description != null && p.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Description'),
            const SizedBox(height: 8),
            Text(p.description!, style: const TextStyle(height: 1.5)),
          ],
          if (p.attributes.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionTitle('Caracteristiques'),
            const SizedBox(height: 8),
            for (final a in p.attributes)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(
                      width: 140,
                      child: Text(a.label,
                          style: const TextStyle(color: AppColors.inkSoft))),
                  Expanded(
                      child: Text(a.display,
                          style: const TextStyle(fontWeight: FontWeight.w600))),
                ]),
              ),
          ],
          const SizedBox(height: 24),
          ProductReviews(reviews: vm.reviews, questions: vm.questions),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
            color: AppColors.grey1, borderRadius: BorderRadius.circular(8)),
        child: Text(text, style: const TextStyle(fontSize: 12)),
      );
}

class _VariantChip extends StatelessWidget {
  const _VariantChip(
      {required this.variant, required this.selected, required this.onTap});
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
          color: selected
              ? AppColors.orange
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.orange : AppColors.grey2),
        ),
        child: Text(
          disabled ? '${variant.label} (epuise)' : variant.label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : (disabled ? AppColors.grey3 : AppColors.ink),
            fontWeight: FontWeight.w600,
            decoration: disabled ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}
