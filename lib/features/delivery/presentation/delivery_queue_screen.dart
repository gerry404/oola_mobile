import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/order.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/delivery_providers.dart';

/// File des livraisons disponibles pour le livreur.
class DeliveryQueueScreen extends ConsumerWidget {
  const DeliveryQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(deliveryQueueProvider);

    return AsyncView(
      value: async,
      onRetry: () => ref.invalidate(deliveryQueueProvider),
      data: (page) {
        if (page.items.isEmpty) {
          return const EmptyState(
            icon: Icons.local_shipping_outlined,
            title: 'Aucune livraison disponible',
            subtitle: 'Revenez plus tard, de nouvelles courses arrivent.',
          );
        }
        return RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async => ref.invalidate(deliveryQueueProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: page.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _DeliveryCard(order: page.items[i]),
          ),
        );
      },
    );
  }
}

class _DeliveryCard extends ConsumerStatefulWidget {
  const _DeliveryCard({required this.order});
  final OrderSummary order;

  @override
  ConsumerState<_DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends ConsumerState<_DeliveryCard> {
  bool _busy = false;

  bool get _canTake =>
      widget.order.status == OrderStatus.paid ||
      widget.order.status == OrderStatus.confirmed;

  Future<void> _take() async {
    final id = widget.order.id;
    if (id == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(deliveryRepositoryProvider).take(id);
      ref.invalidate(deliveryQueueProvider);
      if (mounted) showToast(context, 'Course prise en charge', success: true);
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final id = widget.order.id;
    if (id == null) return;
    final otp = await _askOtp();
    if (otp == null) return;
    setState(() => _busy = true);
    try {
      await ref.read(deliveryRepositoryProvider).confirm(id, otp);
      ref.invalidate(deliveryQueueProvider);
      if (mounted) showToast(context, 'Livraison confirmee', success: true);
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _askOtp() {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Code de confirmation'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Code a 6 chiffres',
            counterText: '',
          ),
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
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('#${o.reference}',
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(formatCFA(o.total),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 8),
          _info(Icons.person_outline, o.customerName ?? '—'),
          if (o.customerPhone != null) _info(Icons.phone_outlined, o.customerPhone!),
          _info(Icons.place_outlined, o.commune ?? '—'),
          if (o.items.isNotEmpty)
            _info(
              Icons.inventory_2_outlined,
              o.items.map((i) => '${i.quantity}x ${i.title}').join(', '),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: _busy
                ? const Center(
                    child: SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: AppColors.orange),
                    ),
                  )
                : (_canTake
                    ? ElevatedButton.icon(
                        onPressed: _take,
                        icon: const Icon(Icons.two_wheeler, size: 20),
                        label: const Text('Prendre en charge'),
                      )
                    : OutlinedButton.icon(
                        onPressed: _confirm,
                        icon: const Icon(Icons.check_circle_outline, size: 20),
                        label: const Text('Confirmer la remise'),
                      )),
          ),
        ],
      ),
    );
  }

  Widget _info(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.inkSoft),
            const SizedBox(width: 8),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, color: AppColors.ink)),
            ),
          ],
        ),
      );
}
