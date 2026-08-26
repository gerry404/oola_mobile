import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/product_card.dart';
import '../../../shared/models/product_detail.dart';
import '../../../shared/models/review.dart';
import '../data/catalog_repository.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(dioProvider));
});

/// Categories du catalogue (mises en cache pour la session).
final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(catalogRepositoryProvider).categories();
});

/// Fiche produit par slug.
final productProvider =
    FutureProvider.family<ProductDetail, String>((ref, slug) {
  return ref.watch(catalogRepositoryProvider).product(slug);
});

/// Avis d'un produit.
final productReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, slug) {
  return ref.watch(catalogRepositoryProvider).reviews(slug);
});

/// Questions/reponses d'un produit.
final productQuestionsProvider =
    FutureProvider.family<List<ProductQuestion>, String>((ref, slug) {
  return ref.watch(catalogRepositoryProvider).questions(slug);
});

/// Etat du feed video : liste cumulee + pagination + chargement incremental.
class FeedState {
  const FeedState({
    this.items = const [],
    this.page = 0,
    this.lastPage = 1,
    this.isLoadingMore = false,
    this.category,
  });

  final List<ProductCard> items;
  final int page;
  final int lastPage;
  final bool isLoadingMore;
  final String? category;

  bool get hasMore => page < lastPage;

  FeedState copyWith({
    List<ProductCard>? items,
    int? page,
    int? lastPage,
    bool? isLoadingMore,
    String? category,
    bool clearCategory = false,
  }) =>
      FeedState(
        items: items ?? this.items,
        page: page ?? this.page,
        lastPage: lastPage ?? this.lastPage,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        category: clearCategory ? null : (category ?? this.category),
      );
}

/// Controleur du feed : premiere page en AsyncValue, pages suivantes en append.
class FeedController extends AsyncNotifier<FeedState> {
  CatalogRepository get _repo => ref.read(catalogRepositoryProvider);

  @override
  Future<FeedState> build() async {
    final first = await _repo.feed(page: 1);
    return FeedState(
      items: first.items,
      page: first.currentPage,
      lastPage: first.lastPage,
    );
  }

  /// Charge la page suivante et l'ajoute a la liste.
  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final next = await _repo.feed(
        page: current.page + 1,
        category: current.category,
      );
      state = AsyncData(current.copyWith(
        items: [...current.items, ...next.items],
        page: next.currentPage,
        lastPage: next.lastPage,
        isLoadingMore: false,
      ));
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  /// Filtre le feed par categorie (null = tout).
  Future<void> setCategory(String? category) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final first = await _repo.feed(page: 1, category: category);
      return FeedState(
        items: first.items,
        page: first.currentPage,
        lastPage: first.lastPage,
        category: category,
      );
    });
  }

  Future<void> refresh() async {
    final cat = state.valueOrNull?.category;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final first = await _repo.feed(page: 1, category: cat);
      return FeedState(
        items: first.items,
        page: first.currentPage,
        lastPage: first.lastPage,
        category: cat,
      );
    });
  }
}

final feedControllerProvider =
    AsyncNotifierProvider<FeedController, FeedState>(FeedController.new);

/// Recherche (famille sur la requete courante).
final searchProvider =
    FutureProvider.family<SearchResult, SearchArgs>((ref, args) {
  return ref.watch(catalogRepositoryProvider).search(
        query: args.query,
        category: args.category,
        sort: args.sort,
      );
});

class SearchArgs {
  const SearchArgs({this.query = '', this.category, this.sort = 'relevance'});
  final String query;
  final String? category;
  final String sort;

  @override
  bool operator ==(Object other) =>
      other is SearchArgs &&
      other.query == query &&
      other.category == category &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(query, category, sort);
}
