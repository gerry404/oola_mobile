import 'package:flutter/material.dart';

import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/feature_placeholder.dart';
import '../../account/presentation/account_tab.dart';

/// Coquille de l'espace acheteur : feed video, recherche, panier, compte.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    FeaturePlaceholder(
      title: 'Feed video',
      icon: Icons.play_circle_fill,
      subtitle: 'Le fil de produits en video arrive ici',
    ),
    FeaturePlaceholder(title: 'Recherche', icon: Icons.search),
    FeaturePlaceholder(title: 'Panier', icon: Icons.shopping_bag_outlined),
    AccountTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const BrandLogo(size: 30)),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle_fill),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Recherche',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Compte',
          ),
        ],
      ),
    );
  }
}
