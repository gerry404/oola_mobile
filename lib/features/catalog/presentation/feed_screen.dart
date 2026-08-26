import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/models/product_card.dart';
import '../../../shared/widgets/async_view.dart';
import '../../cart/application/cart_controller.dart';
import '../../cart/domain/cart_line.dart';
import '../../favorites/application/favorites_controller.dart';
import '../application/catalog_providers.dart';
import 'product_screen.dart';
import 'widgets/feed_video_player.dart';

/// Etat global du son du feed (coupe par defaut, §5).
final feedMutedProvider = StateProvider<bool>((ref) => true);

/// Feed video vertical plein ecran (style reseaux sociaux).
class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedControllerProvider);

    return AsyncView(
      value: feed,
      onRetry: () => ref.read(feedControllerProvider.notifier).refresh(),
      loading: const Center(
        child: CircularProgressIndicator(color: AppColors.orange),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return const EmptyState(
            icon: Icons.videocam_off_outlined,
            title: 'Aucun produit pour le moment',
            subtitle: 'Revenez bientot, le catalogue se remplit.',
          );
        }
        return RefreshIndicator(
          onRefresh: () => ref.read(feedControllerProvider.notifier).refresh(),
          color: AppColors.orange,
          child: PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: state.items.length,
            onPageChanged: (i) {
              setState(() => _current = i);
              // Precharge la page suivante a l'approche de la fin.
              if (i >= state.items.length - 3) {
                ref.read(feedControllerProvider.notifier).loadMore();
              }
            },
            itemBuilder: (context, i) => _FeedItem(
              product: state.items[i],
              isActive: i == _current,
            ),
          ),
        );
      },
    );
  }
}

class _FeedItem extends ConsumerWidget {
  const _FeedItem({required this.product, required this.isActive});

  final ProductCard product;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = ref.watch(feedMutedProvider);
    final isFav = ref.watch(favoritesControllerProvider.select(
      (list) => list.any((f) => f.slug == product.slug),
    ));

    void openProduct() {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ProductScreen(slug: product.slug)),
      );
    }

    return GestureDetector(
      onTap: () => ref.read(feedMutedProvider.notifier).state = !muted,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FeedVideoPlayer(
            videoUrl: product.videoUrl,
            posterUrl: product.posterUrl,
            isActive: isActive,
            muted: muted,
          ),

          // Degrade bas pour lisibilite du texte.
          const _BottomScrim(),

          // Icone son.
          Positioned(
            top: 12,
            right: 12,
            child: _RoundIcon(
              icon: muted ? Icons.volume_off : Icons.volume_up,
              onTap: () => ref.read(feedMutedProvider.notifier).state = !muted,
            ),
          ),

          // Badges promo / sponso.
          Positioned(
            top: 12,
            left: 12,
            child: Row(
              children: [
                if (product.onSale) const _Tag(text: 'PROMO', color: AppColors.danger),
                if (product.isSponsored)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: _Tag(text: 'Sponsorise', color: AppColors.warning),
                  ),
              ],
            ),
          ),

          // Rail d'actions a droite.
          Positioned(
            right: 10,
            bottom: 140,
            child: Column(
              children: [
                _ActionButton(
                  icon: isFav ? Icons.favorite : Icons.favorite_border,
                  active: isFav,
                  label: 'Favori',
                  onTap: () {
                    final nowFav = ref.read(favoritesControllerProvider.notifier).toggle(
                          FavoriteItem(
                            slug: product.slug,
                            title: product.title,
                            price: product.effectivePrice,
                            posterUrl: product.posterUrl,
                            shopName: product.shopName,
                          ),
                        );
                    _snack(context, nowFav ? 'Ajoute aux favoris' : 'Retire des favoris');
                  },
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  icon: Icons.add_shopping_cart,
                  label: 'Panier',
                  onTap: () {
                    ref.read(cartControllerProvider.notifier).add(
                          CartLine(
                            slug: product.slug,
                            title: product.title,
                            price: product.effectivePrice,
                            posterUrl: product.posterUrl,
                            shopName: product.shopName,
                          ),
                        );
                    _snack(context, 'Ajoute au panier', success: true);
                  },
                ),
                const SizedBox(height: 18),
                _ActionButton(
                  icon: Icons.info_outline,
                  label: 'Details',
                  onTap: openProduct,
                ),
              ],
            ),
          ),

          // Infos produit en bas.
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
                    Text(
                      product.shopName!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
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

  void _snack(BuildContext context, String msg, {bool success = false}) {
    final m = ScaffoldMessenger.of(context);
    m.clearSnackBars();
    m.showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? AppColors.mint : AppColors.ink,
      duration: const Duration(milliseconds: 1400),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _fmt(product.effectivePrice),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          if (product.onSale) ...[
            const SizedBox(width: 8),
            Text(
              _fmt(product.price),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int v) {
    final s = v.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return '$buf FCFA';
  }
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.center,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              color: active ? AppColors.danger : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
