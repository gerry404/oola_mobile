import 'package:flutter/foundation.dart';

import '../../../data/repositories/vendor/vendor_repository.dart';
import '../../../domain/models/vendor.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class VendorDashboardViewModel extends ChangeNotifier {
  VendorDashboardViewModel({required VendorRepository vendorRepository})
      : _vendor = vendorRepository {
    load = Command0(_load)..execute();
  }

  final VendorRepository _vendor;
  VendorDashboard? _dashboard;
  VendorDashboard? get dashboard => _dashboard;

  late final Command0 load;

  Future<Result<void>> _load() async {
    final res = await _vendor.dashboard();
    switch (res) {
      case Ok(:final value):
        _dashboard = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
