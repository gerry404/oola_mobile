import 'package:flutter/material.dart';

import '../../../domain/models/order.dart';
import '../../../utils/formatters.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/secure_screen.dart';
import '../../core/ui/state_views.dart';
import '../view_models/order_viewmodel.dart';

/// Suivi d'une commande. Ecran protege contre les captures (code de livraison).
class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key, required this.viewModel});

  final OrderViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return SecureScreen(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Commande ${viewModel.reference}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => viewModel.load.execute(),
            ),
          ],
        ),
        body: ListenableBuilder(
          listenable: Listenable.merge([viewModel, viewModel.load]),
          builder: (context, _) {
            final order = viewModel.order;
            if (viewModel.load.running && order == null) {
              return const LoadingIndicator();
            }
            if (order == null) {
              final err = viewModel.load.result;
              return ErrorIndicator(
                message: err is Error ? describeError(err.error) : 'Erreur.',
                onRetry: () => viewModel.load.execute(),
              );
            }
            return RefreshIndicator(
              color: AppColors.orange,
              onRefresh: () => viewModel.load.execute(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Header(order: order),
                  const SizedBox(height: 20),
                  if (order.deliveryCode != null)
                    _DeliveryCode(code: order.deliveryCode!),
                  if (order.deliveryCode != null) const SizedBox(height: 20),
                  _Timeline(steps: order.timeline),
                  const SizedBox(height: 20),
                  _Card(
                    title: 'Articles',
                    child: Column(
                      children: [
                        for (final i in order.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(children: [
                              Text('${i.quantity}x',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.orange)),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: Text(i.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis)),
                              Text(formatCFA(i.lineTotal),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600)),
                            ]),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _Card(
                    title: 'Recapitulatif',
                    child: Column(children: [
                      _row('Sous-total', formatCFA(order.subtotal)),
                      _row('Livraison (${order.commune ?? ""})',
                          formatCFA(order.deliveryFee)),
                      if (order.couponDiscount > 0)
                        _row('Reduction ${order.couponCode ?? ""}',
                            '- ${formatCFA(order.couponDiscount)}'),
                      const Divider(),
                      _row('Total', formatCFA(order.total), bold: true),
                    ]),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _row(String l, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(l,
              style: TextStyle(
                  color: bold ? AppColors.ink : AppColors.inkSoft,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w400)),
          Text(v,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );
}

class _Header extends StatelessWidget {
  const _Header({required this.order});
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
      child: Row(children: [
        Container(
          height: 46,
          width: 46,
          decoration: const BoxDecoration(
              color: AppColors.orange, shape: BoxShape.circle),
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
                  paid
                      ? 'Paiement confirme'
                      : 'Paiement : ${order.paymentStatus ?? "en attente"}',
                  style: TextStyle(
                      color: paid ? AppColors.mint : AppColors.inkSoft,
                      fontSize: 13)),
            ],
          ),
        ),
        Text(formatCFA(order.total),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
      ]),
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
          color: AppColors.ink, borderRadius: BorderRadius.circular(16)),
      child: Column(children: [
        const Text('Code de confirmation',
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 8),
        Text(code,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w900,
                letterSpacing: 10)),
        const SizedBox(height: 8),
        const Text('A communiquer au livreur au moment de la reception.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12)),
      ]),
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
        : (done || current ? AppColors.orange : AppColors.grey3);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              color: done || current ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: done
                ? const Icon(Icons.check, size: 13, color: Colors.white)
                : null,
          ),
          if (!isLast)
            Expanded(child: Container(width: 2, color: AppColors.grey2)),
        ]),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(step.label,
                  style: TextStyle(
                      fontWeight:
                          current ? FontWeight.w800 : FontWeight.w500,
                      color:
                          done || current ? AppColors.ink : AppColors.inkSoft)),
              if (step.reachedAt != null)
                Text(formatDateTimeFr(step.reachedAt!),
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.inkSoft)),
            ],
          ),
        ),
      ]),
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
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
