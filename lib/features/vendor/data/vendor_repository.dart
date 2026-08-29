import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/order.dart';
import '../../../shared/models/paginated.dart';
import '../domain/vendor_models.dart';

/// Acces a l'espace vendeur : dashboard, produits, commandes, portefeuille.
class VendorRepository {
  VendorRepository(this._dio);
  final Dio _dio;

  Future<VendorDashboard> dashboard() async {
    try {
      final res = await _dio.get('/vendor/dashboard');
      return VendorDashboard.fromJson(_map(_map(res.data)['data']));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Paginated<VendorProduct>> products({int page = 1}) async {
    try {
      final res = await _dio.get('/vendor/products', queryParameters: {'page': page});
      return Paginated.fromJson(_map(res.data), VendorProduct.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Cree un produit (etape 1). Renvoie l'id cree.
  Future<int> createProduct(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.post('/vendor/products', data: payload);
      final data = _map(_map(res.data)['data'] ?? res.data);
      return (data['id'] ?? 0) as int;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Televerse la video du produit (fichier local).
  Future<void> uploadVideo(int id, String filePath) async {
    try {
      final form = FormData.fromMap({
        'video': await MultipartFile.fromFile(filePath),
      });
      await _dio.post('/vendor/products/$id/video', data: form);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Soumet un produit a validation (etape finale).
  Future<void> submitProduct(int id) async {
    try {
      await _dio.post('/vendor/products/$id/submit');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('/vendor/products/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Commandes du vendeur par groupe : preparing | delivering | delivered.
  Future<Paginated<OrderSummary>> orders({
    String group = 'preparing',
    int page = 1,
  }) async {
    try {
      final res = await _dio.get('/vendor/orders',
          queryParameters: {'group': group, 'page': page});
      return Paginated.fromJson(_map(res.data), OrderSummary.fromJson);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Marque une commande prete pour l'enlevement (binding par id).
  Future<void> markOrderReady(int orderId) async {
    try {
      await _dio.post('/vendor/orders/$orderId/ready');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<VendorWallet> wallet() async {
    try {
      final res = await _dio.get('/vendor/wallet');
      return VendorWallet.fromJson(_map(_map(res.data)['data']));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Recharge le portefeuille par Mobile Money. Renvoie l'URL de paiement.
  Future<String?> topup(int amount) async {
    try {
      final res = await _dio.post('/vendor/wallet/topup', data: {'amount': amount});
      final data = _map(res.data);
      return (data['payment_url'] ?? data['data']?['payment_url'])?.toString();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Demande de retrait.
  Future<void> requestWithdrawal(int amount, String method) async {
    try {
      await _dio.post('/vendor/wallet/withdrawals',
          data: {'amount': amount, 'method': method});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic> _map(dynamic v) =>
      v is Map<String, dynamic> ? v : Map<String, dynamic>.from(v as Map);
}
