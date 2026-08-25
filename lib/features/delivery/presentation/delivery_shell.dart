import 'package:flutter/material.dart';

import '../../../shared/widgets/brand_logo.dart';
import '../../../shared/widgets/feature_placeholder.dart';
import '../../account/presentation/account_tab.dart';

/// Coquille de l'espace livreur : file des livraisons, compte.
class DeliveryShell extends StatefulWidget {
  const DeliveryShell({super.key});

  @override
  State<DeliveryShell> createState() => _DeliveryShellState();
}

class _DeliveryShellState extends State<DeliveryShell> {
  int _index = 0;

  static const _tabs = <Widget>[
    FeaturePlaceholder(
      title: 'Livraisons',
      icon: Icons.local_shipping_outlined,
      subtitle: 'Livraisons disponibles et prises en charge',
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
              icon: Icon(Icons.local_shipping_outlined),
              label: 'Livraisons'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Compte'),
        ],
      ),
    );
  }
}
