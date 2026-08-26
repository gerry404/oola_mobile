import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/models/address.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/async_view.dart';
import '../application/account_providers.dart';

/// Gestion des adresses de livraison.
class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes adresses')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        onPressed: () => _openForm(context, ref),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
      body: AsyncView(
        value: async,
        onRetry: () => ref.invalidate(addressesProvider),
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(
              icon: Icons.place_outlined,
              title: 'Aucune adresse',
              subtitle: 'Ajoutez une adresse pour accelerer vos commandes.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _AddressTile(
              address: list[i],
              onEdit: () => _openForm(context, ref, existing: list[i]),
              onDelete: () async {
                await ref
                    .read(accountRepositoryProvider)
                    .deleteAddress(list[i].id);
                ref.invalidate(addressesProvider);
              },
            ),
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, WidgetRef ref, {Address? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddressForm(existing: existing),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.place, color: AppColors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(address.label,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.mint.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Par defaut',
                            style: TextStyle(
                                color: AppColors.mint,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text('${address.recipientName} · ${address.phone}',
                    style: const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
                Text(
                  [address.commune, address.street, address.details]
                      .where((e) => e != null && e.isNotEmpty)
                      .join(', '),
                  style: const TextStyle(color: AppColors.inkSoft, fontSize: 13),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => v == 'edit' ? onEdit() : onDelete(),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Modifier')),
              PopupMenuItem(value: 'delete', child: Text('Supprimer')),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm({this.existing});
  final Address? existing;

  @override
  ConsumerState<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends ConsumerState<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.existing?.label);
  late final _recipient =
      TextEditingController(text: widget.existing?.recipientName);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _commune = TextEditingController(text: widget.existing?.commune);
  late final _street = TextEditingController(text: widget.existing?.street);
  late final _details = TextEditingController(text: widget.existing?.details);
  late bool _isDefault = widget.existing?.isDefault ?? false;
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_label, _recipient, _phone, _commune, _street, _details]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _busy = true);
    final address = Address(
      id: widget.existing?.id ?? 0,
      label: _label.text.trim(),
      recipientName: _recipient.text.trim(),
      phone: _phone.text.trim(),
      commune: _commune.text.trim(),
      street: _street.text.trim().isEmpty ? null : _street.text.trim(),
      details: _details.text.trim().isEmpty ? null : _details.text.trim(),
      isDefault: _isDefault,
    );
    try {
      final repo = ref.read(accountRepositoryProvider);
      if (widget.existing != null) {
        await repo.updateAddress(widget.existing!.id, address);
      } else {
        await repo.createAddress(address);
      }
      ref.invalidate(addressesProvider);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing != null ? 'Modifier l\'adresse' : 'Nouvelle adresse',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _field(_label, 'Libelle (Maison, Bureau...)', required: true),
              _field(_recipient, 'Nom du destinataire', required: true),
              _field(_phone, 'Telephone', required: true, phone: true),
              _field(_commune, 'Commune', required: true),
              _field(_street, 'Rue / quartier'),
              _field(_details, 'Details (etage, reperes...)'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeThumbColor: AppColors.orange,
                title: const Text('Definir par defaut'),
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool required = false,
    bool phone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: phone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          final s = (v ?? '').trim();
          if (required && s.isEmpty) return 'Champ requis';
          if (phone && s.isNotEmpty && !RegExp(r'^\+?\d{8,15}$').hasMatch(s)) {
            return 'Numero invalide';
          }
          return null;
        },
      ),
    );
  }
}
