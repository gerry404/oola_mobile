import 'package:flutter/foundation.dart';

import '../../../data/repositories/delivery/delivery_repository.dart';
import '../../../domain/models/order.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class DeliveryViewModel extends ChangeNotifier {
  DeliveryViewModel({required DeliveryRepository deliveryRepository})
      : _delivery = deliveryRepository {
    load = Command0(_load)..execute();
    take = Command1(_take);
    confirm = Command1(_confirm);
  }

  final DeliveryRepository _delivery;
  List<OrderSummary> _items = [];
  List<OrderSummary> get items => _items;

  late final Command0 load;
  late final Command1<void, int> take;
  late final Command1<void, (int orderId, String otp)> confirm;

  Future<Result<void>> _load() async {
    final res = await _delivery.queue();
    switch (res) {
      case Ok(:final value):
        _items = value.items;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _take(int orderId) async {
    final res = await _delivery.take(orderId);
    if (res is Ok) await _load();
    return res;
  }

  Future<Result<void>> _confirm((int, String) c) async {
    final res = await _delivery.confirm(c.$1, c.$2);
    if (res is Ok) await _load();
    return res;
  }
}
