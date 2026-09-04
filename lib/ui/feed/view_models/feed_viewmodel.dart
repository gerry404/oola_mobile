import 'package:flutter/foundation.dart';

import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../domain/models/product.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel du feed video : premiere page + pagination incrementale.
class FeedViewModel extends ChangeNotifier {
  FeedViewModel({required CatalogRepository catalogRepository})
      : _catalog = catalogRepository {
    load = Command0(_load)..execute();
    loadMore = Command0(_loadMore);
  }

  final CatalogRepository _catalog;

  final List<ProductCard> _items = [];
  int _page = 0;
  int _lastPage = 1;

  List<ProductCard> get items => List.unmodifiable(_items);
  bool get hasMore => _page < _lastPage;

  late final Command0 load;
  late final Command0 loadMore;

  Future<Result<void>> _load() async {
    final res = await _catalog.feed(page: 1);
    switch (res) {
      case Ok(:final value):
        _items
          ..clear()
          ..addAll(value.items);
        _page = value.currentPage;
        _lastPage = value.lastPage;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _loadMore() async {
    if (!hasMore) return const Result.ok(null);
    final res = await _catalog.feed(page: _page + 1);
    switch (res) {
      case Ok(:final value):
        _items.addAll(value.items);
        _page = value.currentPage;
        _lastPage = value.lastPage;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
