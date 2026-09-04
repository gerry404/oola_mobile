import '../../../domain/models/order.dart';
import '../../../domain/models/paginated.dart';
import '../../../utils/parse.dart';
import '../../../utils/result.dart';
import '../../../utils/result_helpers.dart';
import '../../services/api/api_client.dart';

/// Espace livreur : file, prise en charge, confirmation.
class DeliveryRepository {
  DeliveryRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  Future<Result<Paginated<OrderSummary>>> queue({int page = 1}) async {
    final res = await _api.get('/delivery/queue', query: {'page': page});
    return mapResult(res, (v) => Paginated.fromJson(asMap(v), OrderSummary.fromJson));
  }

  Future<Result<void>> take(int orderId) async {
    final res = await _api.post('/delivery/orders/$orderId/take');
    return mapResult(res, (_) {});
  }

  Future<Result<void>> confirm(int orderId, String otp) async {
    final res = await _api.post('/delivery/orders/$orderId/confirm', body: {'otp': otp});
    return mapResult(res, (_) {});
  }
}
