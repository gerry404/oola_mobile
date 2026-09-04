import 'package:flutter/foundation.dart' hide Category;

import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../data/repositories/vendor/vendor_repository.dart';
import '../../../domain/models/category.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class AddProductData {
  const AddProductData({
    required this.title,
    required this.price,
    required this.stock,
    required this.condition,
    required this.videoPath,
    this.description,
    this.categoryId,
  });

  final String title;
  final String? description;
  final int price;
  final int stock;
  final int? categoryId;
  final String condition;
  final String videoPath;
}

class AddProductViewModel extends ChangeNotifier {
  AddProductViewModel({
    required VendorRepository vendorRepository,
    required CatalogRepository catalogRepository,
  })  : _vendor = vendorRepository,
        _catalog = catalogRepository {
    loadCategories = Command0(_loadCategories)..execute();
    publish = Command1(_publish);
  }

  final VendorRepository _vendor;
  final CatalogRepository _catalog;

  List<Category> _categories = [];
  List<Category> get categories => _categories;

  String step = '';

  late final Command0 loadCategories;
  late final Command1<void, AddProductData> publish;

  Future<Result<void>> _loadCategories() async {
    final res = await _catalog.categories();
    if (res is Ok<List<Category>>) {
      _categories = res.value;
      notifyListeners();
    }
    return const Result.ok(null);
  }

  Future<Result<void>> _publish(AddProductData d) async {
    step = 'Creation du produit...';
    notifyListeners();
    final created = await _vendor.createProduct({
      'title': d.title,
      if (d.description != null) 'description': d.description,
      'price': d.price,
      'stock': d.stock,
      if (d.categoryId != null) 'category_id': d.categoryId,
      'condition': d.condition,
    });
    if (created is Error<int>) return Result.error(created.error);
    final id = (created as Ok<int>).value;

    step = 'Envoi de la video...';
    notifyListeners();
    final vid = await _vendor.uploadVideo(id, d.videoPath);
    if (vid is Error) return vid;

    step = 'Envoi a la validation...';
    notifyListeners();
    return _vendor.submitProduct(id);
  }
}
