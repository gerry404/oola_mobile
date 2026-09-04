import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/orders/orders_repository.dart';
import '../../../routing/routes.dart';
import '../../../utils/formatters.dart';
import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/checkout_viewmodel.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.viewModel});

  final CheckoutViewModel viewModel;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _coupon = TextEditingController();
  final _communeCtrl = TextEditingController();

  String? _commune;
  String _payment = 'mobile_money';

  CheckoutViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.placeOrder.addListener(_onPlaced);
  }

  @override
  void dispose() {
    vm.placeOrder.removeListener(_onPlaced);
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _coupon.dispose();
    _communeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onPlaced() async {
    if (vm.placeOrder.completed) {
      final creation = vm.lastCreation;
      vm.placeOrder.clearResult();
      if (creation == null) return;
      if (creation.paymentUrl != null && creation.paymentUrl!.isNotEmpty) {
        await launchUrl(Uri.parse(creation.paymentUrl!),
            mode: LaunchMode.externalApplication);
      }
      if (mounted) context.pushReplacement(Routes.orderWith(creation.reference));
    } else if (vm.placeOrder.error) {
      final r = vm.placeOrder.result;
      if (r is Error<OrderCreation>) {
        showAppSnack(context, describeError(r.error));
      }
      vm.placeOrder.clearResult();
    }
  }

  void _submit(int fee) {
    if (!_formKey.currentState!.validate()) return;
    if (_commune == null) {
      showAppSnack(context, 'Choisissez votre commune');
      return;
    }
    vm.placeOrder.execute(CheckoutData(
      name: _name.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      commune: _commune!,
      paymentMethod: _payment,
      coupon: _coupon.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Commander')),
      body: ListenableBuilder(
        listenable: Listenable.merge([vm, vm.loadZones, vm.placeOrder]),
        builder: (context, _) {
          if (vm.loadZones.running && vm.zones.isEmpty) {
            return const LoadingIndicator();
          }
          final fee = vm.feeFor(_commune);
          final total = vm.subtotal + (fee ?? 0);
          final busy = vm.placeOrder.running;

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
                  decoration: const InputDecoration(
                      labelText: 'Telephone (Mobile Money)'),
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
                      labelText: 'Email (facultatif, pour le recu)'),
                ),
                const SizedBox(height: 20),
                const _Label('Livraison'),
                _CommuneField(
                  controller: _communeCtrl,
                  communes: vm.communes,
                  selected: _commune,
                  feeFor: vm.feeFor,
                  onSelected: (c) => setState(() => _commune = c),
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
                _Recap(subtotal: vm.subtotal, fee: fee, total: total),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: busy || fee == null ? null : () => _submit(fee),
                  child: busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white))
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

/// Saisie de la commune en autocompletion : on tape, seules les correspondances
/// s'affichent, puis on ne voit que le lieu retenu et son montant.
class _CommuneField extends StatefulWidget {
  const _CommuneField({
    required this.controller,
    required this.communes,
    required this.selected,
    required this.feeFor,
    required this.onSelected,
  });

  final TextEditingController controller;
  final List<String> communes;
  final String? selected;
  final int? Function(String?) feeFor;
  final ValueChanged<String?> onSelected;

  @override
  State<_CommuneField> createState() => _CommuneFieldState();
}

class _CommuneFieldState extends State<_CommuneField> {
  bool _open = false;

  List<String> get _matches {
    final q = widget.controller.text.trim().toLowerCase();
    if (q.isEmpty) return const [];
    if (widget.selected != null && q == widget.selected!.toLowerCase()) {
      return const [];
    }
    return widget.communes
        .where((c) => c.toLowerCase().contains(q))
        .take(8)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final fee = widget.feeFor(widget.selected);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: const InputDecoration(
            labelText: 'Ville ou commune',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (_) {
            setState(() => _open = true);
            if (widget.selected != null) widget.onSelected(null);
          },
          onTap: () => setState(() => _open = true),
        ),
        if (_open && _matches.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.grey2),
            ),
            child: Column(
              children: [
                for (final c in _matches)
                  ListTile(
                    dense: true,
                    title: Text(c),
                    onTap: () {
                      widget.controller.text = c;
                      widget.onSelected(c);
                      setState(() => _open = false);
                      FocusScope.of(context).unfocus();
                    },
                  ),
              ],
            ),
          ),
        if (widget.selected != null && fee != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  const Icon(Icons.place, size: 18, color: AppColors.orange),
                  const SizedBox(width: 8),
                  Text(widget.selected!,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ]),
                Text('Livraison ${formatCFA(fee)}',
                    style: const TextStyle(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
      ],
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
        border: Border.all(color: AppColors.grey1),
      ),
      child: Column(children: [
        _row('Sous-total', formatCFA(subtotal)),
        const SizedBox(height: 8),
        _row('Livraison', fee != null ? formatCFA(fee!) : '—'),
        const Divider(height: 20),
        _row('Total', formatCFA(total), bold: true),
      ]),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l,
              style: TextStyle(
                  color: bold ? AppColors.ink : AppColors.inkSoft,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
                  fontSize: bold ? 17 : 14)),
          Text(v,
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
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.orange : AppColors.grey2,
              width: selected ? 1.6 : 1),
        ),
        child: Row(children: [
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
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected ? AppColors.orange : AppColors.grey3),
        ]),
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
