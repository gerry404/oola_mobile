import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/cart/cart_repository.dart';
import '../../../domain/models/cart_line.dart';
import '../../../domain/models/product.dart';
import '../../../routing/routes.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/feed_viewmodel.dart';
import 'feed_video_player.dart';

/// Feed video vertical plein ecran.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key, required this.viewModel});

  final FeedViewModel viewModel;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _pageController = PageController();
  int _current = 0;
  bool _muted = true;

  FeedViewModel get vm => widget.viewModel;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([vm, vm.load]),
      builder: (context, _) {
        final items = vm.items;
        if (vm.load.running && items.isEmpty) return const LoadingIndicator();
        if (vm.load.error && items.isEmpty) {
          final err = vm.load.result;
          return ErrorIndicator(
            message: err is Error ? describeError(err.error) : 'Erreur.',
            onRetry: () => vm.load.execute(),
          );
        }
        if (items.isEmpty) {
          return const EmptyState(
            icon: Icons.videocam_off_outlined,
            title: 'Aucun produit pour le moment',
            subtitle: 'Revenez bientot, le catalogue se remplit.',
          );
        }
        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () => vm.load.execute(),
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: items.length,
            onPageChanged: (i) {
              setState(() => _current = i);
              if (i >= items.length - 3) vm.loadMore.execute();
            },
            itemBuilder: (context, i) => _FeedItem(
              product: items[i],
              isActive: i == _current,
              muted: _muted,
              onToggleMute: () => setState(() => _muted = !_muted),
            ),
          ),
        );
      },
    );
  }
}

class _FeedItem extends StatelessWidget {
  const _FeedItem({
    required this.product,
    required this.isActive,
    required this.muted,
    required this.onToggleMute,
  });

  final ProductCard product;
  final bool isActive;
  final bool muted;
  final VoidCallback onToggleMute;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartRepository>();

    void openProduct() => context.push(Routes.productWith(product.slug));

    return GestureDetector(
      onTap: onToggleMute,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FeedVideoPlayer(
            videoUrl: product.videoUrl,
            posterUrl: product.posterUrl,
            isActive: isActive,
            muted: muted,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.center,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _RoundIcon(
              icon: muted ? Icons.volume_off : Icons.volume_up,
              onTap: onToggleMute,
            ),
          ),
          if (product.onSale)
            const Positioned(
              top: 12,
              left: 12,
              child: _Tag(text: 'PROMO', color: AppColors.danger),
            ),
          Positioned(
            right: 10,
            bottom: 140,
            child: Column(
              children: [
                Consumer<CartRepository>(
                  builder: (context, c, _) => _ActionButton(
                    icon: c.isFavorite(product.slug)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    active: c.isFavorite(product.slug),
                    label: 'Favori',
                    onTap: () {
                      final now = c.toggleFavorite(FavoriteItem(
                        slug: product.slug,
                        title: product.title,
                        price: product.effectivePrice,
                        posterUrl: product.posterUrl,
                        shopName: product.shopName,
                      ));
                      showAppSnack(context,
                          now ? 'Ajoute aux favoris' : 'Retire des favoris');
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  icon: Icons.add_shopping_cart,
                  label: 'Panier',
                  onTap: () {
                    cart.addToCart(CartLine(
                      slug: product.slug,
                      title: product.title,
                      price: product.effectivePrice,
                      posterUrl: product.posterUrl,
                      shopName: product.shopName,
                    ));
                    showAppSnack(context, 'Ajoute au panier', success: true);
                  },
                ),
                const SizedBox(height: 18),
                _ActionButton(
                    icon: Icons.info_outline,
                    label: 'Details',
                    onTap: openProduct),
              ],
            ),
          ),
          Positioned(
            left: 16,
            right: 80,
            bottom: 28,
            child: GestureDetector(
              onTap: openProduct,
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.shopName != null)
                    Text(product.shopName!,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(product.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2)),
                  const SizedBox(height: 8),
                  _PriceChip(product: product),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.product});
  final ProductCard product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.orange,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _fmt(product.effectivePrice),
        style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return '$b FCFA';
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
              color: Colors.black38, borderRadius: BorderRadius.circular(20)),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(24)),
              child: Icon(icon,
                  color: active ? AppColors.danger : Colors.white, size: 24),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      );
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5)),
      );
}
