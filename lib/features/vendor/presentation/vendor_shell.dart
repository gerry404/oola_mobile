import 'package:flutter/material.dart';

import '../../../shared/widgets/brand_logo.dart';
import '../../account/presentation/account_tab.dart';
import 'vendor_dashboard_tab.dart';
import 'vendor_orders_tab.dart';
import 'vendor_products_tab.dart';
import 'vendor_wallet_tab.dart';

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
    VendorDashboardTab(),
    VendorProductsTab(),
    VendorOrdersTab(),
    VendorWalletTab(),
    AccountTab(),
  ];

  static const _titles = [
    'Tableau de bord',
    'Mes produits',
    'Commandes',
    'Portefeuille',
    'Compte',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _index == 0
            ? const BrandLogo(size: 28)
            : Text(_titles[_index]),
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Bord'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined), label: 'Produits'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), label: 'Commandes'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined), label: 'Solde'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Compte'),
        ],
      ),
    );
  }
}
