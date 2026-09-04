import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/themes/colors.dart';
import '../../core/ui/product_grid_card.dart';
import '../../core/ui/state_views.dart';
import '../view_models/search_viewmodel.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.viewModel});

  final SearchViewModel viewModel;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  SearchViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    // Chargement initial : catalogue populaire (requete vide).
    vm.search.execute((query: '', category: null));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      vm.search.execute((query: value.trim(), category: vm.category));
    });
  }

  void _setCategory(String? slug) {
    vm.search.execute((query: vm.query, category: slug));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([vm, vm.search]),
      builder: (context, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _controller,
                onChanged: _onQuery,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Rechercher un produit, une boutique...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _controller.clear();
                            _onQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _CatChip(
                    label: 'Tout',
                    selected: vm.category == null,
                    onTap: () => _setCategory(null),
                  ),
                  for (final c in vm.categories)
                    _CatChip(
                      label: c.name,
                      selected: vm.category == c.slug,
                      onTap: () => _setCategory(c.slug),
                    ),
                ],
              ),
            ),
            Expanded(child: _results()),
          ],
        );
      },
    );
  }

  Widget _results() {
    if (vm.search.running && vm.results.isEmpty) return const LoadingIndicator();
    if (vm.results.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: vm.query.isEmpty ? 'Recherchez un produit' : 'Aucun resultat',
        subtitle: vm.query.isEmpty
            ? 'Ou filtrez par categorie.'
            : 'Essayez d\'autres mots-cles.',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.62,
      ),
      itemCount: vm.results.length,
      itemBuilder: (_, i) => ProductGridCard(product: vm.results[i]),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip(
      {required this.label, required this.selected, required this.onTap});
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
            color: selected
                ? AppColors.orange
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? AppColors.orange : AppColors.grey2),
          ),
          child: Text(label,
              style: TextStyle(
                  color: selected ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ),
    );
  }
}
