import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/vendor/vendor_repository.dart';
import '../../../data/services/biometric_service.dart';
import '../../account/widgets/account_screen.dart';
import '../../core/ui/brand_logo.dart';
import '../view_models/vendor_dashboard_viewmodel.dart';
import '../view_models/vendor_products_viewmodel.dart';
import '../view_models/vendor_wallet_viewmodel.dart';
import 'vendor_dashboard_screen.dart';
import 'vendor_orders_screen.dart';
import 'vendor_products_screen.dart';
import 'vendor_wallet_screen.dart';

/// Coquille vendeur : tableau de bord, produits, commandes, portefeuille, compte.
class VendorShell extends StatefulWidget {
  const VendorShell({super.key});

  @override
  State<VendorShell> createState() => _VendorShellState();
}

class _VendorShellState extends State<VendorShell> {
  int _index = 0;
  late final VendorDashboardViewModel _dashVm;
  late final VendorProductsViewModel _productsVm;
  late final VendorWalletViewModel _walletVm;

  static const _titles = [
    'Tableau de bord',
    'Mes produits',
    'Commandes',
    'Portefeuille',
    'Compte',
  ];

  @override
  void initState() {
    super.initState();
    final repo = context.read<VendorRepository>();
    _dashVm = VendorDashboardViewModel(vendorRepository: repo);
    _productsVm = VendorProductsViewModel(vendorRepository: repo);
    _walletVm = VendorWalletViewModel(
      vendorRepository: repo,
      biometric: context.read<BiometricService>(),
      authRepository: context.read<AuthRepository>(),
    );
  }

  @override
  void dispose() {
    _dashVm.dispose();
    _productsVm.dispose();
    _walletVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _index == 0
            ? const BrandLogo(size: 28)
            : Text(_titles[_index]),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          VendorDashboardScreen(viewModel: _dashVm),
          VendorProductsScreen(viewModel: _productsVm),
          const VendorOrdersScreen(),
          VendorWalletScreen(viewModel: _walletVm),
          const AccountScreen(),
        ],
      ),
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
