import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_colors.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/product_grid_card.dart';
import '../application/catalog_providers.dart';

/// Recherche produits + filtres par categorie.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  SearchArgs _args = const SearchArgs();

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _args = SearchArgs(query: value.trim(), category: _args.category));
    });
  }

  void _setCategory(String? slug) {
    setState(() => _args = SearchArgs(query: _args.query, category: slug));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final results = ref.watch(searchProvider(_args));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            controller: _controller,
            onChanged: _onQueryChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit, une boutique...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.clear();
                        _onQueryChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Filtres categories.
        categories.maybeWhen(
          data: (list) => SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _CatChip(
                  label: 'Tout',
                  selected: _args.category == null,
                  onTap: () => _setCategory(null),
                ),
                for (final c in list)
                  _CatChip(
                    label: c.name,
                    selected: _args.category == c.slug,
                    onTap: () => _setCategory(c.slug),
                  ),
              ],
            ),
          ),
          orElse: () => const SizedBox(height: 44),
        ),

        Expanded(
          child: AsyncView(
            value: results,
            onRetry: () => ref.invalidate(searchProvider(_args)),
            data: (res) {
              if (res.products.items.isEmpty) {
                return EmptyState(
                  icon: Icons.search_off,
                  title: _args.query.isEmpty
                      ? 'Commencez a taper pour rechercher'
                      : 'Aucun resultat',
                  subtitle: _args.query.isEmpty
                      ? 'Ou filtrez par categorie.'
                      : 'Essayez d\'autres mots-cles.',
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemCount: res.products.items.length,
                itemBuilder: (_, i) =>
                    ProductGridCard(product: res.products.items[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: selected ? AppColors.orange : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.orange : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
