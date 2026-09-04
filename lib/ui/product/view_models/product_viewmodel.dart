import 'package:flutter/foundation.dart';

import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/review.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel de la fiche produit : charge produit + avis + questions.
class ProductViewModel extends ChangeNotifier {
  ProductViewModel({
    required CatalogRepository catalogRepository,
    required this.slug,
  }) : _catalog = catalogRepository {
    load = Command0(_load)..execute();
  }

  final CatalogRepository _catalog;
  final String slug;

  ProductDetail? _product;
  List<Review> _reviews = [];
  List<ProductQuestion> _questions = [];

  ProductDetail? get product => _product;
  List<Review> get reviews => _reviews;
  List<ProductQuestion> get questions => _questions;

  late final Command0 load;

  Future<Result<void>> _load() async {
    final res = await _catalog.product(slug);
    switch (res) {
      case Error(:final error):
        return Result.error(error);
      case Ok(:final value):
        _product = value;
        notifyListeners();
    }
    // Avis et questions : non bloquants (on ignore leurs erreurs).
    final r = await _catalog.reviews(slug);
    if (r is Ok<List<Review>>) _reviews = r.value;
    final q = await _catalog.questions(slug);
    if (q is Ok<List<ProductQuestion>>) _questions = q.value;
    notifyListeners();
    return const Result.ok(null);
  }
}
