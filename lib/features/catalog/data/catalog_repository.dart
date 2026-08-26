import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/category.dart';
import '../../../shared/models/paginated.dart';
import '../../../shared/models/product_card.dart';
import '../../../shared/models/product_detail.dart';
import '../../../shared/models/review.dart';

/// Resultat de recherche : produits pagines + boutiques correspondantes.
class SearchResult {
  const SearchResult({required this.products, required this.shops});
  final Paginated<ProductCard> products;
  final List<ShopHit> shops;
}

/// Boutique remontee par la recherche.
class ShopHit {
  const ShopHit({
    required this.id,
    required this.slug,
    required this.name,
    this.isCertified = false,
  });
  final int id;
  final String slug;
  final String name;
  final bool isCertified;
}

/// Acces en lecture au catalogue public (feed, produit, recherche, categories).
class CatalogRepository {
  CatalogRepository(this._dio);
  final Dio _dio;

  /// Feed principal (produits video), pagine.
  Future<Paginated<ProductCard>> feed({int page = 1, String? category}) async {
    try {
      final res = await _dio.get('/feed', queryParameters: {
        'page': page,
        if (category != null) 'cat': category,
      });
      return Paginated.fromJson(_map(res.data), ProductCard.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Fiche produit detaillee.
  Future<ProductDetail> product(String slug) async {
    try {
      final res = await _dio.get('/products/$slug');
      return ProductDetail.fromJson(_map(_map(res.data)['data']));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Avis d'un produit (premiere page).
  Future<List<Review>> reviews(String slug, {int page = 1}) async {
    try {
      final res = await _dio.get('/products/$slug/reviews',
          queryParameters: {'page': page});
      // data peut etre un paginator Laravel { data: [...] }.
      final data = _map(res.data)['data'];
      final list = data is Map ? (data['data'] ?? []) : (data ?? []);
      return (list as List).map((e) => Review.fromJson(_map(e))).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Questions/reponses d'un produit.
  Future<List<ProductQuestion>> questions(String slug, {int page = 1}) async {
    try {
      final res = await _dio.get('/products/$slug/questions',
          queryParameters: {'page': page});
      final data = _map(res.data)['data'];
      final list = data is Map ? (data['data'] ?? []) : (data ?? []);
      return (list as List)
          .map((e) => ProductQuestion.fromJson(_map(e)))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Categories triees.
  Future<List<Category>> categories() async {
    try {
      final res = await _dio.get('/categories');
      final list = res.data is List ? res.data : _map(res.data)['data'];
      return (list as List).map((e) => Category.fromJson(_map(e))).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Recherche produits + boutiques.
  Future<SearchResult> search({
    required String query,
    String? category,
    String sort = 'relevance',
    int page = 1,
  }) async {
    try {
      final res = await _dio.get('/search', queryParameters: {
        if (query.isNotEmpty) 'q': query,
        if (category != null) 'cat': category,
        'sort': sort,
        'page': page,
      });
      final data = _map(res.data);
      final products = Paginated.fromJson(
        {'data': data['products'], 'meta': data['meta']},
        ProductCard.fromJson,
      );
      final shops = (data['shops'] as List? ?? [])
          .map((e) => _map(e))
          .map((m) => ShopHit(
                id: (m['id'] ?? 0) as int,
                slug: (m['slug'] ?? '').toString(),
                name: (m['name'] ?? '').toString(),
                isCertified: m['is_certified'] == true,
              ))
          .toList();
      return SearchResult(products: products, shops: shops);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic> _map(dynamic v) =>
      v is Map<String, dynamic> ? v : Map<String, dynamic>.from(v as Map);
}
