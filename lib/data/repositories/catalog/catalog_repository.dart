import '../../../domain/models/category.dart';
import '../../../domain/models/paginated.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/review.dart';
import '../../../utils/result.dart';

/// Acces en lecture au catalogue public.
abstract class CatalogRepository {
  Future<Result<Paginated<ProductCard>>> feed({int page = 1, String? category});
  Future<Result<ProductDetail>> product(String slug);
  Future<Result<List<Review>>> reviews(String slug);
  Future<Result<List<ProductQuestion>>> questions(String slug);
  Future<Result<List<Category>>> categories();
  Future<Result<Paginated<ProductCard>>> search({
    required String query,
    String? category,
    String sort = 'relevance',
    int page = 1,
  });
}
