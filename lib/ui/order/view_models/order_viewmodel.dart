import 'package:flutter/foundation.dart';

import '../../../data/repositories/orders/orders_repository.dart';
import '../../../domain/models/order.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class OrderViewModel extends ChangeNotifier {
  OrderViewModel({
    required OrdersRepository ordersRepository,
    required this.reference,
  }) : _orders = ordersRepository {
    load = Command0(_load)..execute();
  }

  final OrdersRepository _orders;
  final String reference;

  OrderDetail? _order;
  OrderDetail? get order => _order;

  late final Command0 load;

  Future<Result<void>> _load() async {
    final res = await _orders.order(reference);
    switch (res) {
      case Ok(:final value):
        _order = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
