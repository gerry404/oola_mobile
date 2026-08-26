import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/security/secure_screen.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/order.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/orders_providers.dart';

/// Suivi d'une commande : statut, timeline, code de remise au livreur.
///
/// Ecran protege contre les captures (le code de livraison y figure, §3.2).
class OrderTrackingScreen extends ConsumerWidget {
  const OrderTrackingScreen({super.key, required this.reference});
  final String reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(orderProvider(reference));

    return SecureScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Commande $reference'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(orderProvider(reference)),
            ),
          ],
        ),
        body: AsyncView(
          value: async,
          onRetry: () => ref.invalidate(orderProvider(reference)),
          data: (order) => RefreshIndicator(
            color: AppColors.orange,
            onRefresh: () async => ref.invalidate(orderProvider(reference)),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StatusHeader(order: order),
                const SizedBox(height: 20),
                if (order.deliveryCode != null) _DeliveryCode(code: order.deliveryCode!),
                if (order.deliveryCode != null) const SizedBox(height: 20),
                _Timeline(steps: order.timeline),
                const SizedBox(height: 20),
                _ItemsCard(order: order),
                const SizedBox(height: 16),
                _TotalsCard(order: order),
                if (order.deliveryUserName != null) ...[
                  const SizedBox(height: 16),
                  _DeliveryUser(order: order),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});
  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final paid = order.isPaid;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: const BoxDecoration(
              color: AppColors.orange,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.status.label,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800)),
                Text(
                  paid ? 'Paiement confirme' : 'Paiement : ${order.paymentStatus ?? "en attente"}',
                  style: TextStyle(
                    color: paid ? AppColors.mint : AppColors.inkSoft,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(formatCFA(order.total),
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _DeliveryCode extends StatelessWidget {
  const _DeliveryCode({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text('Code de confirmation',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text(
            code,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w900,
              letterSpacing: 10,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A communiquer au livreur au moment de la reception.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.steps});
  final List<OrderStep> steps;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(step: steps[i], isLast: i == steps.length - 1),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.isLast});
  final OrderStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final done = step.isDone;
    final current = step.isCurrent;
    final color = step.terminal
        ? AppColors.danger
        : (done || current ? AppColors.orange : AppColors.gray300);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 22,
                width: 22,
                decoration: BoxDecoration(
                  color: done || current ? color : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: done
                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: AppColors.gray200),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.label,
                  style: TextStyle(
                    fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                    color: done || current ? AppColors.ink : AppColors.inkSoft,
                  ),
                ),
                if (step.reachedAt != null)
                  Text(formatDateTimeFr(step.reachedAt!),
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.inkSoft)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});
  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Articles',
      child: Column(
        children: [
          for (final i in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Text('${i.quantity}x',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, color: AppColors.orange)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(i.title,
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        if (i.variant != null)
                          Text(i.variant!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.inkSoft)),
                      ],
                    ),
                  ),
                  Text(formatCFA(i.lineTotal),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _TotalsCard extends StatelessWidget {
  const _TotalsCard({required this.order});
  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Recapitulatif',
      child: Column(
        children: [
          _row('Sous-total', formatCFA(order.subtotal)),
          _row('Livraison (${order.commune ?? ""})', formatCFA(order.deliveryFee)),
          if (order.couponDiscount > 0)
            _row('Reduction ${order.couponCode ?? ""}',
                '- ${formatCFA(order.couponDiscount)}'),
          const Divider(),
          _row('Total', formatCFA(order.total), bold: true),
        ],
      ),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l,
                style: TextStyle(
                    color: bold ? AppColors.ink : AppColors.inkSoft,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
            Text(v,
                style: TextStyle(
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
          ],
        ),
      );
}

class _DeliveryUser extends StatelessWidget {
  const _DeliveryUser({required this.order});
  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Livreur',
      child: Row(
        children: [
          const Icon(Icons.delivery_dining, color: AppColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(order.deliveryUserName ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          if (order.deliveryUserPhone != null)
            Text(order.deliveryUserPhone!,
                style: const TextStyle(color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
