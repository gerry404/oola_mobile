import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../data/repositories/cart/cart_repository.dart';
import '../../../domain/models/cart_line.dart';
import '../../../routing/routes.dart';
import '../../../utils/formatters.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';

/// Panier. [asTab] true quand affiche comme onglet du shell acheteur.
class CartScreen extends StatelessWidget {
  const CartScreen({super.key, this.asTab = true});

  final bool asTab;

  @override
  Widget build(BuildContext context) {
    final body = Consumer<CartRepository>(
      builder: (context, cart, _) {
        if (cart.lines.isEmpty) {
          return const EmptyState(
            icon: Icons.shopping_bag_outlined,
            title: 'Votre panier est vide',
            subtitle: 'Parcourez le feed et ajoutez des produits.',
          );
        }
        return Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cart.lines.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _CartTile(line: cart.lines[i]),
              ),
            ),
            _Summary(subtotal: cart.subtotal),
          ],
        );
      },
    );

    if (asTab) return body;
    return Scaffold(appBar: AppBar(title: const Text('Panier')), body: body);
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartRepository>();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey1),
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
                          Container(color: AppColors.grey1),
                    )
                  : Container(color: AppColors.grey1),
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
                onMinus: () =>
                    cart.setQuantity(line.key, line.quantity - 1),
                onPlus: () => cart.setQuantity(line.key, line.quantity + 1),
              ),
              TextButton(
                onPressed: () => cart.removeFromCart(line.key),
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
  const _QtyStepper(
      {required this.quantity, required this.onMinus, required this.onPlus});
  final int quantity;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.grey2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _btn(Icons.remove, onMinus),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text('$quantity',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        _btn(Icons.add, onPlus),
      ]),
    );
  }

  Widget _btn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 16)),
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
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: const Border(top: BorderSide(color: AppColors.grey1)),
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
                onPressed: () => context.push(Routes.checkout),
                child: const Text('Passer la commande'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
