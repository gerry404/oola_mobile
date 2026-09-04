import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../domain/models/order.dart';
import '../../../utils/formatters.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/delivery_viewmodel.dart';

class DeliveryQueueScreen extends StatelessWidget {
  const DeliveryQueueScreen({super.key, required this.viewModel});

  final DeliveryViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, viewModel.load]),
      builder: (context, _) {
        if (viewModel.load.running && viewModel.items.isEmpty) {
          return const LoadingIndicator();
        }
        if (viewModel.items.isEmpty) {
          return const EmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'Aucune livraison disponible',
            subtitle: 'Revenez plus tard, de nouvelles courses arrivent.',
          );
        }
        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () => viewModel.load.execute(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) =>
                _DeliveryCard(order: viewModel.items[i], viewModel: viewModel),
          ),
        );
      },
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.order, required this.viewModel});
  final OrderSummary order;
  final DeliveryViewModel viewModel;

  bool get _canTake =>
      order.status == OrderStatus.paid || order.status == OrderStatus.confirmed;

  Future<void> _confirm(BuildContext context) async {
    final id = order.id;
    if (id == null) return;
    final controller = TextEditingController();
    final otp = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Code de confirmation'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration:
              const InputDecoration(labelText: 'Code a 6 chiffres', counterText: ''),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (otp != null && otp.isNotEmpty) viewModel.confirm.execute((id, otp));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel.take, viewModel.confirm]),
      builder: (context, _) {
        final busy = viewModel.take.running || viewModel.confirm.running;
        _maybeError(context, viewModel.take);
        _maybeError(context, viewModel.confirm);
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grey1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text('#${order.reference}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                Text(formatCFA(order.total),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 8),
              _info(Icons.person_outline, order.customerName ?? '—'),
              if (order.customerPhone != null)
                _info(Icons.phone_outlined, order.customerPhone!),
              _info(Icons.place_outlined, order.commune ?? '—'),
              if (order.items.isNotEmpty)
                _info(
                    Icons.inventory_2_outlined,
                    order.items
                        .map((i) => '${i.quantity}x ${i.title}')
                        .join(', ')),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: busy
                    ? const Center(
                        child: SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.2, color: AppColors.orange)))
                    : (_canTake
                        ? ElevatedButton.icon(
                            onPressed: () {
                              final id = order.id;
                              if (id != null) viewModel.take.execute(id);
                            },
                            icon: const Icon(Icons.two_wheeler, size: 20),
                            label: const Text('Prendre en charge'),
                          )
                        : OutlinedButton.icon(
                            onPressed: () => _confirm(context),
                            icon: const Icon(Icons.check_circle_outline,
                                size: 20),
                            label: const Text('Confirmer la remise'),
                          )),
              ),
            ],
          ),
        );
      },
    );
  }

  void _maybeError(BuildContext context, dynamic command) {
    if (command.error == true) {
      final r = command.result as Result?;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (r is Error) showAppSnack(context, describeError(r.error));
        command.clearResult();
      });
    }
  }

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: AppColors.inkSoft),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ]),
      );
}
