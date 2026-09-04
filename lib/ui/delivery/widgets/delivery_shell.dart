import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/delivery/delivery_repository.dart';
import '../../account/widgets/account_screen.dart';
import '../../core/ui/brand_logo.dart';
import '../view_models/delivery_viewmodel.dart';
import 'delivery_queue_screen.dart';

/// Coquille livreur : file des livraisons, compte.
class DeliveryShell extends StatefulWidget {
  const DeliveryShell({super.key});

  @override
  State<DeliveryShell> createState() => _DeliveryShellState();
}

class _DeliveryShellState extends State<DeliveryShell> {
  int _index = 0;
  late final DeliveryViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = DeliveryViewModel(deliveryRepository: context.read<DeliveryRepository>());
  }

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _index == 0 ? const BrandLogo(size: 28) : const Text('Compte'),
      ),
      body: IndexedStack(
        index: _index,
        children: [
          DeliveryQueueScreen(viewModel: _vm),
          const AccountScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'Livraisons'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Compte'),
        ],
      ),
    );
  }
}
