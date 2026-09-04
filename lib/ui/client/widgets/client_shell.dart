import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/cart/cart_repository.dart';
import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../account/widgets/account_screen.dart';
import '../../cart/widgets/cart_screen.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/brand_logo.dart';
import '../../feed/view_models/feed_viewmodel.dart';
import '../../feed/widgets/feed_screen.dart';
import '../../search/view_models/search_viewmodel.dart';
import '../../search/widgets/search_screen.dart';

/// Coquille acheteur : feed video, recherche, panier, compte.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;
  late final FeedViewModel _feedVm;
  late final SearchViewModel _searchVm;

  static const _titles = ['', 'Recherche', 'Panier', 'Compte'];

  @override
  void initState() {
    super.initState();
    final catalog = context.read<CatalogRepository>();
    _feedVm = FeedViewModel(catalogRepository: catalog);
    _searchVm = SearchViewModel(catalogRepository: catalog);
  }

  @override
  void dispose() {
    _feedVm.dispose();
    _searchVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFeed = _index == 0;
    return Scaffold(
      backgroundColor: isFeed ? Colors.black : null,
      extendBodyBehindAppBar: isFeed,
      appBar: isFeed
          ? null
          : AppBar(title: Text(_titles[_index])),
      body: IndexedStack(
        index: _index,
        children: [
          FeedScreen(viewModel: _feedVm),
          SearchScreen(viewModel: _searchVm),
          const CartScreen(asTab: true),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.play_circle_outline),
              activeIcon: Icon(Icons.play_circle_fill),
              label: 'Accueil'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.search), label: 'Recherche'),
          BottomNavigationBarItem(
              icon: Consumer<CartRepository>(
                builder: (context, cart, _) =>
                    _CartIcon(count: cart.count, filled: false),
              ),
              activeIcon: Consumer<CartRepository>(
                builder: (context, cart, _) =>
                    _CartIcon(count: cart.count, filled: true),
              ),
              label: 'Panier'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Compte'),
        ],
      ),
    );
  }
}

class _CartIcon extends StatelessWidget {
  const _CartIcon({required this.count, required this.filled});
  final int count;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Stack(clipBehavior: Clip.none, children: [
      Icon(filled ? Icons.shopping_bag : Icons.shopping_bag_outlined),
      if (count > 0)
        Positioned(
          right: -8,
          top: -6,
          child: Container(
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
            decoration:
                const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
            child: Text(count > 99 ? '99+' : '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800)),
          ),
        ),
    ]);
  }
}

/// En-tete de marque (pour les autres coquilles).
class ShellBrand extends StatelessWidget {
  const ShellBrand({super.key});
  @override
  Widget build(BuildContext context) => const BrandLogo(size: 28);
}
