import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/delivery_zone.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/async_view.dart';
import '../../auth/application/auth_controller.dart';
import '../../orders/application/orders_providers.dart';
import '../../security/biometric_gate.dart';
import '../../orders/presentation/order_tracking_screen.dart';
import '../application/cart_controller.dart';

/// Ecran de validation de commande.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _coupon = TextEditingController();

  String? _commune;
  String _payment = 'mobile_money';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Prefill depuis le compte connecte si disponible.
    final user = ref.read(authControllerProvider).user;
    if (user != null) {
      _name.text = user.name;
      if (user.phone != null) _phone.text = user.phone!;
      if (user.email != null) _email.text = user.email!;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _coupon.dispose();
    super.dispose();
  }

  int? _feeFor(List<DeliveryZone> zones, String? commune) {
    if (commune == null) return null;
    for (final z in zones) {
      if (z.communes.any((c) => c.toLowerCase() == commune.toLowerCase())) {
        return z.fee;
      }
    }
    return null;
  }

  Future<void> _submit(int deliveryFee) async {
    if (!_formKey.currentState!.validate()) return;
    if (_commune == null) {
      showToast(context, 'Choisissez votre commune');
      return;
    }
    final lines = ref.read(cartControllerProvider);
    if (lines.isEmpty) {
      showToast(context, 'Votre panier est vide');
      return;
    }

    // Operation sensible (§3.2) : verification biometrique avant paiement.
    if (_payment == 'mobile_money') {
      final ok = await ref
          .read(biometricGateProvider)
          .require(context, reason: 'Confirmez pour payer');
      if (!ok) return;
    }

    setState(() => _busy = true);
    try {
      final res = await ref.read(ordersRepositoryProvider).create(
            items: lines,
            customerName: _name.text.trim(),
            customerPhone: _phone.text.trim(),
            customerEmail: _email.text.trim(),
            commune: _commune!,
            paymentMethod: _payment,
            couponCode: _coupon.text.trim(),
          );

      // Vide le panier apres creation reussie.
      ref.read(cartControllerProvider.notifier).clear();

      // Paiement en ligne : ouvre la page de paiement securisee.
      if (res.paymentUrl != null && res.paymentUrl!.isNotEmpty) {
        final uri = Uri.parse(res.paymentUrl!);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(reference: res.reference),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message);
    } catch (_) {
      if (mounted) showToast(context, 'La commande a echoue. Reessayez.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(deliveryZonesProvider);
    final subtotal = ref.watch(cartSubtotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commander')),
      body: AsyncView(
        value: zonesAsync,
        onRetry: () => ref.invalidate(deliveryZonesProvider),
        data: (zones) {
          final communes = <String>[
            for (final z in zones) ...z.communes,
          ]..sort();
          final fee = _feeFor(zones, _commune);
          final total = subtotal + (fee ?? 0);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _Label('Coordonnees'),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nom complet'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration:
                      const InputDecoration(labelText: 'Telephone (Mobile Money)'),
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return 'Telephone requis';
                    if (!RegExp(r'^\+?\d{8,15}$').hasMatch(s)) {
                      return 'Numero invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email (facultatif, pour le recu)',
                  ),
                ),

                const SizedBox(height: 20),
                const _Label('Livraison'),
                DropdownButtonFormField<String>(
                  initialValue: _commune,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Commune'),
                  items: [
                    for (final c in communes)
                      DropdownMenuItem(value: c, child: Text(c)),
                  ],
                  onChanged: (v) => setState(() => _commune = v),
                ),

                const SizedBox(height: 20),
                const _Label('Paiement'),
                _PayOption(
                  value: 'mobile_money',
                  group: _payment,
                  title: 'Mobile Money',
                  subtitle: 'Orange, MTN, Moov, Wave',
                  icon: Icons.smartphone,
                  onTap: () => setState(() => _payment = 'mobile_money'),
                ),
                _PayOption(
                  value: 'cash_on_delivery',
                  group: _payment,
                  title: 'Paiement a la livraison',
                  subtitle: 'Reglez en especes a la reception',
                  icon: Icons.payments_outlined,
                  onTap: () => setState(() => _payment = 'cash_on_delivery'),
                ),

                const SizedBox(height: 20),
                const _Label('Code promo (facultatif)'),
                TextFormField(
                  controller: _coupon,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(labelText: 'Code'),
                ),

                const SizedBox(height: 24),
                _Recap(subtotal: subtotal, fee: fee, total: total),

                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _busy || fee == null ? null : () => _submit(fee),
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white),
                        )
                      : Text(_payment == 'mobile_money'
                          ? 'Payer ${formatCFA(total)}'
                          : 'Confirmer la commande'),
                ),
                if (_commune != null && fee == null)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Cette commune n\'est pas encore couverte par la livraison.',
                      style: TextStyle(color: AppColors.danger, fontSize: 12),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Recap extends StatelessWidget {
  const _Recap({required this.subtotal, required this.fee, required this.total});
  final int subtotal;
  final int? fee;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        children: [
          _row('Sous-total', formatCFA(subtotal)),
          const SizedBox(height: 8),
          _row('Livraison', fee != null ? formatCFA(fee!) : '—'),
          const Divider(height: 20),
          _row('Total', formatCFA(total), bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: bold ? AppColors.ink : AppColors.inkSoft,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
                  fontSize: bold ? 17 : 14)),
          Text(value,
              style: TextStyle(
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                  fontSize: bold ? 17 : 14)),
        ],
      );
}

class _PayOption extends StatelessWidget {
  const _PayOption({
    required this.value,
    required this.group,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String value;
  final String group;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == group;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.orange : AppColors.gray200,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.orange : AppColors.inkSoft),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.inkSoft)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.orange : AppColors.gray300,
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      );
}
