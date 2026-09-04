import 'package:flutter/foundation.dart';

import '../../../data/repositories/vendor/vendor_repository.dart';
import '../../../domain/models/vendor.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class VendorProductsViewModel extends ChangeNotifier {
  VendorProductsViewModel({required VendorRepository vendorRepository})
      : _vendor = vendorRepository {
    load = Command0(_load)..execute();
    submit = Command1(_submit);
    remove = Command1(_remove);
  }

  final VendorRepository _vendor;
  List<VendorProduct> _items = [];
  List<VendorProduct> get items => _items;

  late final Command0 load;
  late final Command1<void, int> submit;
  late final Command1<void, int> remove;

  Future<Result<void>> _load() async {
    final res = await _vendor.products();
    switch (res) {
      case Ok(:final value):
        _items = value.items;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _submit(int id) async {
    final res = await _vendor.submitProduct(id);
    if (res is Ok) await _load();
    return res;
  }

  Future<Result<void>> _remove(int id) async {
    final res = await _vendor.deleteProduct(id);
    if (res is Ok) await _load();
    return res;
  }
}
