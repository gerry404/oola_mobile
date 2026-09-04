import 'package:flutter/foundation.dart';

import '../../../data/repositories/account/account_repository.dart';
import '../../../domain/models/app_notification.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class NotificationsViewModel extends ChangeNotifier {
  NotificationsViewModel({required AccountRepository accountRepository})
      : _account = accountRepository {
    load = Command0(_load)..execute();
    markAllRead = Command0(_markAllRead);
  }

  final AccountRepository _account;
  List<AppNotification> _items = [];
  List<AppNotification> get items => _items;

  late final Command0 load;
  late final Command0 markAllRead;

  Future<Result<void>> _load() async {
    final res = await _account.notifications();
    switch (res) {
      case Ok(:final value):
        _items = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<void>> _markAllRead() async {
    final res = await _account.markAllNotificationsRead();
    if (res is Ok) await _load();
    return res;
  }
}
