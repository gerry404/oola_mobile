import 'package:flutter/foundation.dart';

import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/cart/cart_repository.dart';
import '../../../data/repositories/orders/orders_repository.dart';
import '../../../data/services/biometric_service.dart';
import '../../../domain/models/delivery_zone.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

/// Donnees du formulaire de commande.
class CheckoutData {
  const CheckoutData({
    required this.name,
    required this.phone,
    required this.commune,
    required this.paymentMethod,
    this.email,
    this.coupon,
  });

  final String name;
  final String phone;
  final String? email;
  final String commune;
  final String paymentMethod;
  final String? coupon;
}

class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel({
    required OrdersRepository ordersRepository,
    required CartRepository cartRepository,
    required BiometricService biometric,
    required AuthRepository authRepository,
  })  : _orders = ordersRepository,
        _cart = cartRepository,
        _biometric = biometric,
        _auth = authRepository {
    loadZones = Command0(_loadZones)..execute();
    placeOrder = Command1(_placeOrder);
  }

  final OrdersRepository _orders;
  final CartRepository _cart;
  final BiometricService _biometric;
  final AuthRepository _auth;

  List<DeliveryZone> _zones = [];
  OrderCreation? lastCreation;

  List<DeliveryZone> get zones => _zones;
  int get subtotal => _cart.subtotal;

  late final Command0 loadZones;
  late final Command1<OrderCreation, CheckoutData> placeOrder;

  /// Frais pour une commune (null si non couverte).
  int? feeFor(String? commune) {
    if (commune == null) return null;
    for (final z in _zones) {
      if (z.communes.any((c) => c.toLowerCase() == commune.toLowerCase())) {
        return z.fee;
      }
    }
    return null;
  }

  List<String> get communes {
    final all = <String>[for (final z in _zones) ...z.communes];
    all.sort();
    return all;
  }

  Future<Result<void>> _loadZones() async {
    final res = await _orders.deliveryZones();
    if (res is Ok<List<DeliveryZone>>) {
      _zones = res.value;
      notifyListeners();
    }
    return switch (res) {
      Ok() => const Result.ok(null),
      Error(:final error) => Result.error(error),
    };
  }

  Future<Result<OrderCreation>> _placeOrder(CheckoutData d) async {
    // Operation sensible : verification biometrique avant paiement (§3.2).
    if (d.paymentMethod == 'mobile_money' && await _auth.isBiometricEnabled()) {
      final auth =
          await _biometric.authenticate(reason: 'Confirmez pour payer');
      if (auth != BiometricResult.success) {
        return Result.error(Exception('Verification annulee.'));
      }
    }

    final res = await _orders.create(
      items: _cart.lines,
      customerName: d.name,
      customerPhone: d.phone,
      customerEmail: d.email,
      commune: d.commune,
      paymentMethod: d.paymentMethod,
      couponCode: d.coupon,
    );
    switch (res) {
      case Ok(:final value):
        lastCreation = value;
        _cart.clearCart();
        return Result.ok(value);
      case Error(:final error):
        return Result.error(error);
    }
  }
}
