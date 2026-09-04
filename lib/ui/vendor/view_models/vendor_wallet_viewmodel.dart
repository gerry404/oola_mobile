import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/vendor/vendor_repository.dart';
import '../../../data/services/biometric_service.dart';
import '../../../domain/models/vendor.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class VendorWalletViewModel extends ChangeNotifier {
  VendorWalletViewModel({
    required VendorRepository vendorRepository,
    required BiometricService biometric,
    required AuthRepository authRepository,
  })  : _vendor = vendorRepository,
        _biometric = biometric,
        _auth = authRepository {
    load = Command0(_load)..execute();
    topup = Command1(_topup);
    withdraw = Command1(_withdraw);
  }

  final VendorRepository _vendor;
  final BiometricService _biometric;
  final AuthRepository _auth;

  VendorWallet? _wallet;
  String? lastTopupUrl;
  VendorWallet? get wallet => _wallet;

  late final Command0 load;
  late final Command1<String?, int> topup;
  late final Command1<void, int> withdraw;

  Future<Result<void>> _load() async {
    final res = await _vendor.wallet();
    switch (res) {
      case Ok(:final value):
        _wallet = value;
        notifyListeners();
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<Result<String?>> _topup(int amount) async {
    final res = await _vendor.topup(amount);
    if (res is Ok<String?>) {
      lastTopupUrl = res.value;
      await _load();
    }
    return res;
  }

  Future<Result<void>> _withdraw(int amount) async {
    // Operation sensible : verification biometrique si activee.
    if (await _auth.isBiometricEnabled()) {
      final auth =
          await _biometric.authenticate(reason: 'Confirmez le retrait');
      if (auth != BiometricResult.success) {
        return Result.error(Exception('Verification annulee.'));
      }
    }
    final res = await _vendor.requestWithdrawal(amount, 'mobile_money');
    if (res is Ok) await _load();
    return res;
  }
}
