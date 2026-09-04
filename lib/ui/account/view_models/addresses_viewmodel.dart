import 'package:flutter/foundation.dart';

import '../../../data/repositories/account/account_repository.dart';
import '../../../domain/models/address.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class AddressesViewModel extends ChangeNotifier {
  AddressesViewModel({required AccountRepository accountRepository})
      : _account = accountRepository {
    load = Command0(_load)..execute();
    save = Command1(_save);
    remove = Command1(_remove);
  }

  final AccountRepository _account;
  List<Address> _items = [];
  List<Address> get items => _items;

  late final Command0 load;
  late final Command1<void, Address> save;
  late final Command1<void, int> remove;

  Future<Result<void>> _load() async {
    final res = await _account.addresses();
    switch (res) {
      case Ok(:final value):
        _items = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _save(Address a) async {
    final res =
        a.id == 0 ? await _account.createAddress(a) : await _account.updateAddress(a.id, a);
    if (res is Ok) await _load();
    return res;
  }

  Future<Result<void>> _remove(int id) async {
    final res = await _account.deleteAddress(id);
    if (res is Ok) await _load();
    return res;
  }
}
