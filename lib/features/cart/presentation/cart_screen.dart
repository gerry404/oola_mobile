import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/cart_controller.dart';
import '../domain/cart_line.dart';
import 'checkout_screen.dart';

/// Panier : contenu (embarque comme onglet, sans AppBar retour).
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key, this.asTab = true});

  /// true quand affiche comme onglet du shell acheteur.
  final bool asTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lines = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    final body = lines.isEmpty
        ? const EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Votre panier est vide',
            subtitle: 'Parcourez le feed et ajoutez des produits.',
          )
        : Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _CartTile(line: lines[i]),
                ),
              ),
              _Summary(subtotal: subtotal),
            ],
          );

    if (asTab) return body;
    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: body,
    );
  }
}

class _CartTile extends ConsumerWidget {
  const _CartTile({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(cartControllerProvider.notifier);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 64,
              width: 64,
              child: line.posterUrl != null
                  ? CachedNetworkImage(
                      imageUrl: line.posterUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.gray100),
                    )
                  : Container(color: AppColors.gray100),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (line.variantLabel != null)
                  Text(line.variantLabel!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 4),
                Text(formatCFA(line.price),
                    style: const TextStyle(
                        color: AppColors.orange, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          Column(
            children: [
              _QtyStepper(
                quantity: line.quantity,
                onMinus: () => ctrl.decrement(line.key),
                onPlus: () => ctrl.increment(line.key),
              ),
              TextButton(
                onPressed: () => ctrl.remove(line.key),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
                    foregroundColor: AppColors.danger),
                child: const Text('Retirer', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.quantity,
    required this.onMinus,
    required this.onPlus,
  });

  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _btn(Icons.remove, onMinus),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('$quantity',
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          _btn(Icons.add, onPlus),
        ],
      ),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16),
        ),
      );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.subtotal});
  final int subtotal;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.gray100)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total',
                    style: TextStyle(color: AppColors.inkSoft)),
                Text(formatCFA(subtotal),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Frais de livraison calcules a l\'etape suivante selon la commune.',
              style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                ),
                child: const Text('Passer la commande'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
