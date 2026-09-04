import 'package:dio/dio.dart';

import '../../../domain/models/order.dart';
import '../../../domain/models/paginated.dart';
import '../../../domain/models/vendor.dart';
import '../../../utils/parse.dart';
import '../../../utils/result.dart';
import '../../../utils/result_helpers.dart';
import '../../services/api/api_client.dart';

/// Espace vendeur : dashboard, produits, commandes, portefeuille.
class VendorRepository {
  VendorRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  Future<Result<VendorDashboard>> dashboard() async {
    final res = await _api.get('/vendor/dashboard');
    return mapResult(res, (v) => VendorDashboard.fromJson(asMap(asMap(v)['data'])));
  }

  Future<Result<Paginated<VendorProduct>>> products({int page = 1}) async {
    final res = await _api.get('/vendor/products', query: {'page': page});
    return mapResult(res, (v) => Paginated.fromJson(asMap(v), VendorProduct.fromJson));
  }

  /// Cree un produit (etape 1). Renvoie l'id.
  Future<Result<int>> createProduct(Map<String, dynamic> payload) async {
    final res = await _api.post('/vendor/products', body: payload);
    return mapResult(res, (v) => asInt(asMap(asMap(v)['data'])['id']));
  }

  Future<Result<void>> uploadVideo(int id, String filePath) async {
    final form = FormData.fromMap({'video': await MultipartFile.fromFile(filePath)});
    final res = await _api.postMultipart('/vendor/products/$id/video', form);
    return mapResult(res, (_) {});
  }

  Future<Result<void>> submitProduct(int id) async {
    final res = await _api.post('/vendor/products/$id/submit');
    return mapResult(res, (_) {});
  }

  Future<Result<void>> deleteProduct(int id) async {
    final res = await _api.delete('/vendor/products/$id');
    return mapResult(res, (_) {});
  }

  Future<Result<Paginated<OrderSummary>>> orders({
    String group = 'preparing',
    int page = 1,
  }) async {
    final res =
        await _api.get('/vendor/orders', query: {'group': group, 'page': page});
    return mapResult(res, (v) => Paginated.fromJson(asMap(v), OrderSummary.fromJson));
  }

  Future<Result<void>> markOrderReady(int orderId) async {
    final res = await _api.post('/vendor/orders/$orderId/ready');
    return mapResult(res, (_) {});
  }

  Future<Result<VendorWallet>> wallet() async {
    final res = await _api.get('/vendor/wallet');
    return mapResult(res, (v) => VendorWallet.fromJson(asMap(asMap(v)['data'])));
  }

  /// Recharge Mobile Money. Renvoie l'URL de paiement eventuelle.
  Future<Result<String?>> topup(int amount) async {
    final res = await _api.post('/vendor/wallet/topup', body: {'amount': amount});
    return mapResult(res, (v) {
      final map = asMap(v);
      return asStringOrNull(map['payment_url'] ?? asMap(map['data'])['payment_url']);
    });
  }

  Future<Result<void>> requestWithdrawal(int amount, String method) async {
    final res = await _api
        .post('/vendor/wallet/withdrawals', body: {'amount': amount, 'method': method});
    return mapResult(res, (_) {});
  }
}
