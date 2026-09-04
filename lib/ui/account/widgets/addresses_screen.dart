import 'package:flutter/material.dart';

import '../../../domain/models/address.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/addresses_viewmodel.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key, required this.viewModel});

  final AddressesViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes adresses')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.orange,
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Ajouter', style: TextStyle(color: Colors.white)),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([viewModel, viewModel.load]),
        builder: (context, _) {
          if (viewModel.load.running && viewModel.items.isEmpty) {
            return const LoadingIndicator();
          }
          if (viewModel.items.isEmpty) {
            return const EmptyState(
              icon: Icons.place_outlined,
              title: 'Aucune adresse',
              subtitle: 'Ajoutez une adresse pour accelerer vos commandes.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final a = viewModel.items[i];
              return _AddressTile(
                address: a,
                onEdit: () => _openForm(context, existing: a),
                onDelete: () => viewModel.remove.execute(a.id),
              );
            },
          );
        },
      ),
    );
  }

  void _openForm(BuildContext context, {Address? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddressForm(viewModel: viewModel, existing: existing),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile(
      {required this.address, required this.onEdit, required this.onDelete});
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.place, color: AppColors.orange),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(address.label,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                if (address.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(6)),
                    child: const Text('Par defaut',
                        style: TextStyle(
                            color: AppColors.mint,
                            fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text('${address.recipientName} · ${address.phone}',
                  style:
                      const TextStyle(color: AppColors.inkSoft, fontSize: 13)),
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
      ]),
    );
  }
}

class _AddressForm extends StatefulWidget {
  const _AddressForm({required this.viewModel, this.existing});
  final AddressesViewModel viewModel;
  final Address? existing;

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final _label = TextEditingController(text: widget.existing?.label);
  late final _recipient =
      TextEditingController(text: widget.existing?.recipientName);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _commune = TextEditingController(text: widget.existing?.commune);
  late final _street = TextEditingController(text: widget.existing?.street);
  late final _details = TextEditingController(text: widget.existing?.details);
  late bool _isDefault = widget.existing?.isDefault ?? false;

  @override
  void initState() {
    super.initState();
    widget.viewModel.save.addListener(_onSaved);
  }

  @override
  void dispose() {
    widget.viewModel.save.removeListener(_onSaved);
    for (final c in [_label, _recipient, _phone, _commune, _street, _details]) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSaved() {
    if (widget.viewModel.save.completed && mounted) {
      widget.viewModel.save.clearResult();
      Navigator.of(context).pop();
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.viewModel.save.execute(Address(
      id: widget.existing?.id ?? 0,
      label: _label.text.trim(),
      recipientName: _recipient.text.trim(),
      phone: _phone.text.trim(),
      commune: _commune.text.trim(),
      street: _street.text.trim().isEmpty ? null : _street.text.trim(),
      details: _details.text.trim().isEmpty ? null : _details.text.trim(),
      isDefault: _isDefault,
    ));
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
              Text(widget.existing != null ? 'Modifier l\'adresse' : 'Nouvelle adresse',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
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
              ListenableBuilder(
                listenable: widget.viewModel.save,
                builder: (context, _) => ElevatedButton(
                  onPressed:
                      widget.viewModel.save.running ? null : _submit,
                  child: widget.viewModel.save.running
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.2, color: Colors.white))
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {bool required = false, bool phone = false}) {
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
