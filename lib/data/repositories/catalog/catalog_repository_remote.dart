import '../../../domain/models/category.dart';
import '../../../domain/models/paginated.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/review.dart';
import '../../../utils/parse.dart';
import '../../../utils/result.dart';
import '../../../utils/result_helpers.dart';
import '../../services/api/api_client.dart';
import 'catalog_repository.dart';

class CatalogRepositoryRemote implements CatalogRepository {
  CatalogRepositoryRemote({required ApiClient apiClient}) : _api = apiClient;

  final ApiClient _api;

  @override
  Future<Result<Paginated<ProductCard>>> feed({int page = 1, String? category}) async {
    final res = await _api.get('/feed', query: {
      'page': page,
      if (category != null) 'cat': category,
    });
    return mapResult(
        res, (v) => Paginated.fromJson(asMap(v), ProductCard.fromJson));
  }

  @override
  Future<Result<ProductDetail>> product(String slug) async {
    final res = await _api.get('/products/$slug');
    return mapResult(res, (v) => ProductDetail.fromJson(asMap(asMap(v)['data'])));
  }

  @override
  Future<Result<List<Review>>> reviews(String slug) async {
    final res = await _api.get('/products/$slug/reviews');
    return mapResult(res, (v) {
      final data = asMap(v)['data'];
      final list = data is Map ? asList(data['data']) : asList(data);
      return list.map((e) => Review.fromJson(asMap(e))).toList();
    });
  }

  @override
  Future<Result<List<ProductQuestion>>> questions(String slug) async {
    final res = await _api.get('/products/$slug/questions');
    return mapResult(res, (v) {
      final data = asMap(v)['data'];
      final list = data is Map ? asList(data['data']) : asList(data);
      return list.map((e) => ProductQuestion.fromJson(asMap(e))).toList();
    });
  }

  @override
  Future<Result<List<Category>>> categories() async {
    final res = await _api.get('/categories');
    return mapResult(res, (v) {
      final list = v is List ? v : asList(asMap(v)['data']);
      return list.map((e) => Category.fromJson(asMap(e))).toList();
    });
  }

  @override
  Future<Result<Paginated<ProductCard>>> search({
    required String query,
    String? category,
    String sort = 'relevance',
    int page = 1,
  }) async {
    final res = await _api.get('/search', query: {
      if (query.isNotEmpty) 'q': query,
      if (category != null) 'cat': category,
      'sort': sort,
      'page': page,
    });
    return mapResult(res, (v) {
      final data = asMap(v);
      return Paginated.fromJson(
        {'data': data['products'], 'meta': data['meta']},
        ProductCard.fromJson,
      );
    });
  }
}
