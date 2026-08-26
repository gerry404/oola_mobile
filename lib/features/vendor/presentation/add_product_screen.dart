import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../catalog/application/catalog_providers.dart';
import '../application/vendor_providers.dart';

/// Ajout d'un produit etape par etape : informations, video, puis soumission.
class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _price = TextEditingController();
  final _stock = TextEditingController(text: '1');
  final _externalUrl = TextEditingController();

  int? _categoryId;
  String _condition = 'new';
  XFile? _video;
  bool _busy = false;
  String _step = '';

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _price.dispose();
    _stock.dispose();
    _externalUrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final file = await picker.pickVideo(source: ImageSource.gallery);
    if (file != null) setState(() => _video = file);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_video == null && _externalUrl.text.trim().isEmpty) {
      showToast(context, 'Ajoutez une video (fichier ou lien).');
      return;
    }

    setState(() => _busy = true);
    final repo = ref.read(vendorRepositoryProvider);
    try {
      setState(() => _step = 'Creation du produit...');
      final id = await repo.createProduct({
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'price': int.parse(_price.text.trim()),
        'stock': int.parse(_stock.text.trim()),
        if (_categoryId != null) 'category_id': _categoryId,
        'condition': _condition,
      });

      setState(() => _step = 'Envoi de la video...');
      if (_video != null) {
        await repo.uploadVideo(id, _video!.path);
      } else {
        await repo.uploadVideoUrl(id, _externalUrl.text.trim());
      }

      setState(() => _step = 'Envoi a la validation...');
      await repo.submitProduct(id);

      if (mounted) {
        showToast(context, 'Produit envoye a la validation', success: true);
        Navigator.of(context).pop(true);
      }
    } on ApiException catch (e) {
      if (mounted) showToast(context, e.message);
    } catch (_) {
      if (mounted) showToast(context, 'Echec de l\'ajout. Reessayez.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau produit')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Titre du produit'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Titre requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _description,
                maxLines: 3,
                decoration:
                    const InputDecoration(labelText: 'Description (facultatif)'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
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
                ],
              ),
              const SizedBox(height: 12),
              categories.maybeWhen(
                data: (list) => DropdownButtonFormField<int>(
                  initialValue: _categoryId,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                  items: [
                    for (final c in list)
                      DropdownMenuItem(value: c.id, child: Text(c.name)),
                  ],
                  onChanged: (v) => setState(() => _categoryId = v),
                ),
                orElse: () => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              const Text('Etat',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: [
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
                        color: _condition == e.$1 ? Colors.white : AppColors.ink,
                      ),
                      onSelected: (_) => setState(() => _condition = e.$1),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              const Text('Video du produit',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              _VideoPicker(
                video: _video,
                onPick: _pickVideo,
                onClear: () => setState(() => _video = null),
              ),
              const SizedBox(height: 8),
              const Text('Ou collez un lien video (TikTok, YouTube, Instagram)',
                  style: TextStyle(fontSize: 12, color: AppColors.inkSoft)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _externalUrl,
                enabled: _video == null,
                decoration: const InputDecoration(labelText: 'Lien video'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.2, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Text(_step, style: const TextStyle(fontSize: 14)),
                        ],
                      )
                    : const Text('Publier le produit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoPicker extends StatelessWidget {
  const _VideoPicker({
    required this.video,
    required this.onPick,
    required this.onClear,
  });

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
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.mint),
            const SizedBox(width: 10),
            Expanded(
              child: Text(video!.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClear,
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: onPick,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.gray200, style: BorderStyle.solid, width: 1.4),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.video_call_outlined,
                size: 30, color: AppColors.orange),
            SizedBox(height: 6),
            Text('Choisir une video depuis la galerie',
                style: TextStyle(color: AppColors.inkSoft)),
          ],
        ),
      ),
    );
  }
}
