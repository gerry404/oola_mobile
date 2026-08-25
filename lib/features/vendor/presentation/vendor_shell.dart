import 'package:flutter/material.dart';

import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/feature_placeholder.dart';
import '../../account/presentation/account_tab.dart';

/// Coquille de l'espace vendeur : tableau de bord, produits, commandes,
/// portefeuille, compte.
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    FeaturePlaceholder(
      title: 'Tableau de bord',
      icon: Icons.insights,
      subtitle: 'Ventes, commandes et solde',
    ),
    FeaturePlaceholder(title: 'Produits', icon: Icons.inventory_2_outlined),
    FeaturePlaceholder(title: 'Commandes', icon: Icons.receipt_long),
    FeaturePlaceholder(
      title: 'Portefeuille',
      icon: Icons.account_balance_wallet_outlined,
    ),
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
              icon: Icon(Icons.insights), label: 'Bord'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined), label: 'Produits'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Commandes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              label: 'Solde'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Compte'),
        ],
      ),
    );
  }
}
