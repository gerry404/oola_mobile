import 'package:flutter/foundation.dart' hide Category;

import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../domain/models/category.dart';
import '../../../domain/models/product.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({required CatalogRepository catalogRepository})
      : _catalog = catalogRepository {
    loadCategories = Command0(_loadCategories)..execute();
    search = Command1(_search);
  }

  final CatalogRepository _catalog;

  List<Category> _categories = [];
  List<ProductCard> _results = [];
  String _query = '';
  String? _category;

  List<Category> get categories => _categories;
  List<ProductCard> get results => _results;
  String get query => _query;
  String? get category => _category;

  late final Command0 loadCategories;
  late final Command1<void, ({String query, String? category})> search;

  Future<Result<void>> _loadCategories() async {
    final res = await _catalog.categories();
    if (res is Ok<List<Category>>) {
      _categories = res.value;
      notifyListeners();
    }
    return const Result.ok(null);
  }

  Future<Result<void>> _search(({String query, String? category}) args) async {
    _query = args.query;
    _category = args.category;
    final res = await _catalog.search(query: args.query, category: args.category);
    switch (res) {
      case Ok(:final value):
        _results = value.items;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
