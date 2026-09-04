import 'package:flutter/foundation.dart';

import '../../../data/repositories/vendor/vendor_repository.dart';
import '../../../domain/models/order.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// ViewModel des commandes vendeur pour un groupe donne
/// (preparing / delivering / delivered / cancelled).
class VendorOrdersViewModel extends ChangeNotifier {
  VendorOrdersViewModel({
    required VendorRepository vendorRepository,
    required this.group,
  }) : _vendor = vendorRepository {
    load = Command0(_load)..execute();
    markReady = Command1(_markReady);
  }

  final VendorRepository _vendor;
  final String group;

  List<OrderSummary> _items = [];
  List<OrderSummary> get items => _items;

  late final Command0 load;
  late final Command1<void, int> markReady;

  Future<Result<void>> _load() async {
    final res = await _vendor.orders(group: group);
    switch (res) {
      case Ok(:final value):
        _items = value.items;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _markReady(int orderId) async {
    final res = await _vendor.markOrderReady(orderId);
    if (res is Ok) await _load();
    return res;
  }
}
