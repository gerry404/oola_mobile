import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/result.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/state_views.dart';
import '../view_models/add_product_viewmodel.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key, required this.viewModel});

  final AddProductViewModel viewModel;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '1');

  int? _categoryId;
  String _condition = 'new';
  XFile? _video;

  AddProductViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    vm.publish.addListener(_onPublish);
  }

  @override
  void dispose() {
    vm.publish.removeListener(_onPublish);
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    super.dispose();
  }

  void _onPublish() {
    if (vm.publish.completed) {
      vm.publish.clearResult();
      if (mounted) {
        showAppSnack(context, 'Produit envoye a la validation', success: true);
        context.pop(true);
      }
    } else if (vm.publish.error) {
      final r = vm.publish.result;
      if (r is Error) showAppSnack(context, describeError(r.error));
      vm.publish.clearResult();
    }
  }

  Future<void> _pickVideo() async {
    final file = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (file != null) setState(() => _video = file);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_video == null) {
      showAppSnack(context, 'Ajoutez une video du produit.');
      return;
    }
    vm.publish.execute(AddProductData(
      title: _title.text.trim(),
      description:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
      price: int.parse(_price.text.trim()),
      stock: int.parse(_stock.text.trim()),
      categoryId: _categoryId,
      condition: _condition,
      videoPath: _video!.path,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau produit')),
      body: ListenableBuilder(
        listenable: Listenable.merge([vm, vm.publish]),
        builder: (context, _) {
          final busy = vm.publish.running;
          return AbsorbPointer(
            absorbing: busy,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _title,
                    decoration:
                        const InputDecoration(labelText: 'Titre du produit'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Titre requis'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _description,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Description (facultatif)'),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Prix (FCFA)'),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n < 100) return 'Min 100';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stock,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stock'),
                        validator: (v) {
                          final n = int.tryParse((v ?? '').trim());
                          if (n == null || n < 0) return 'Invalide';
                          return null;
                        },
                      ),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  if (vm.categories.isNotEmpty)
                    DropdownButtonFormField<int>(
                      initialValue: _categoryId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Categorie'),
                      items: [
                        for (final c in vm.categories)
                          DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ],
                      onChanged: (v) => setState(() => _categoryId = v),
                    ),
                  const SizedBox(height: 12),
                  const Text('Etat',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  Wrap(spacing: 8, children: [
                    for (final e in const [
                      ('new', 'Neuf'),
                      ('used', 'Occasion'),
                      ('refurbished', 'Reconditionne'),
                    ])
                      ChoiceChip(
                        label: Text(e.$2),
                        selected: _condition == e.$1,
                        selectedColor: AppColors.orange,
                        labelStyle: TextStyle(
                            color: _condition == e.$1
                                ? Colors.white
                                : AppColors.ink),
                        onSelected: (_) => setState(() => _condition = e.$1),
                      ),
                  ]),
                  const SizedBox(height: 20),
                  const Text('Video du produit',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  _VideoPicker(
                    video: _video,
                    onPick: _pickVideo,
                    onClear: () => setState(() => _video = null),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: busy ? null : _submit,
                    child: busy
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.2, color: Colors.white)),
                              const SizedBox(width: 10),
                              Text(vm.step,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          )
                        : const Text('Publier le produit'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VideoPicker extends StatelessWidget {
  const _VideoPicker(
      {required this.video, required this.onPick, required this.onClear});
  final XFile? video;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (video != null) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.mint.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mint.withValues(alpha: 0.4)),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle, color: AppColors.mint),
          const SizedBox(width: 10),
          Expanded(
              child: Text(video!.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
          IconButton(icon: const Icon(Icons.close), onPressed: onClear),
        ]),
      );
    }
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.grey2, width: 1.4),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call_outlined, size: 30, color: AppColors.orange),
            SizedBox(height: 6),
            Text('Choisir une video depuis la galerie',
                style: TextStyle(color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}
