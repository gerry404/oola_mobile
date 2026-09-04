import 'package:flutter/foundation.dart';

import '../../../data/repositories/orders/orders_repository.dart';
import '../../../domain/models/order.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class MyOrdersViewModel extends ChangeNotifier {
  MyOrdersViewModel({required OrdersRepository ordersRepository})
      : _orders = ordersRepository {
    load = Command0(_load)..execute();
  }

  final OrdersRepository _orders;
  List<OrderSummary> _items = [];
  List<OrderSummary> get items => _items;

  late final Command0 load;

  Future<Result<void>> _load() async {
    final res = await _orders.myOrders();
    switch (res) {
      case Ok(:final value):
        _items = value.items;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
