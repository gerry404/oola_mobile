import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/brand_logo.dart';
import '../../account/presentation/account_tab.dart';
import '../../cart/application/cart_controller.dart';
import '../../cart/presentation/cart_screen.dart';
import '../../catalog/presentation/feed_screen.dart';
import '../../catalog/presentation/search_screen.dart';

/// Coquille de l'espace acheteur : feed video, recherche, panier, compte.
class ClientShell extends ConsumerStatefulWidget {
  const ClientShell({super.key});

  @override
  ConsumerState<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends ConsumerState<ClientShell> {
  int _index = 0;

  static const _titles = ['', 'Recherche', 'Panier', 'Compte'];

  @override
  Widget build(BuildContext context) {
    final cartCount = ref.watch(cartCountProvider);
    final isFeed = _index == 0;

    return Scaffold(
      backgroundColor: isFeed ? Colors.black : AppColors.cream,
      extendBodyBehindAppBar: isFeed,
      appBar: isFeed
          ? null
          : AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: const [
          FeedScreen(),
          SearchScreen(),
          CartScreen(asTab: true),
          AccountTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle_fill),
            label: 'Accueil',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: _CartIcon(count: cartCount, filled: false),
            activeIcon: _CartIcon(count: cartCount, filled: true),
            label: 'Panier',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}

/// Icone panier avec badge du nombre d'articles.
class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, required this.filled});
  final int count;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(filled ? Icons.shopping_bag : Icons.shopping_bag_outlined),
        if (count > 0)
          Positioned(
            right: -8,
            top: -6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              decoration: const BoxDecoration(
                color: AppColors.orange,
                shape: BoxShape.circle,
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800),
              ),
            ),
          ),
      ],
    );
  }
}

/// En-tete de marque reutilisable (garde pour d'autres ecrans).
class ClientHeaderLogo extends StatelessWidget {
  const ClientHeaderLogo({super.key});
  @override
  Widget build(BuildContext context) => const BrandLogo(size: 28);
}
