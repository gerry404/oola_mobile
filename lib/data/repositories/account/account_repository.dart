import '../../../domain/models/address.dart';
import '../../../domain/models/app_notification.dart';
import '../../../utils/parse.dart';
import '../../../utils/result.dart';
import '../../../utils/result_helpers.dart';
import '../../services/api/api_client.dart';

/// Compte : adresses et notifications.
class AccountRepository {
  AccountRepository({required ApiClient apiClient}) : _api = apiClient;
  final ApiClient _api;

  Future<Result<List<Address>>> addresses() async {
    final res = await _api.get('/me/addresses');
    return mapResult(res,
        (v) => asList(asMap(v)['data']).map((e) => Address.fromJson(asMap(e))).toList());
  }

  Future<Result<void>> createAddress(Address address) async {
    final res = await _api.post('/me/addresses', body: address.toPayload());
    return mapResult(res, (_) {});
  }

  Future<Result<void>> updateAddress(int id, Address address) async {
    final res = await _api.patch('/me/addresses/$id', body: address.toPayload());
    return mapResult(res, (_) {});
  }

  Future<Result<void>> deleteAddress(int id) async {
    final res = await _api.delete('/me/addresses/$id');
    return mapResult(res, (_) {});
  }

  Future<Result<List<AppNotification>>> notifications() async {
    final res = await _api.get('/me/notifications');
    return mapResult(res, (v) {
      final data = asMap(v)['data'];
      final list = data is Map ? asList(data['data']) : asList(data);
      return list.map((e) => AppNotification.fromJson(asMap(e))).toList();
    });
  }

  Future<Result<void>> markAllNotificationsRead() async {
    final res = await _api.post('/me/notifications/read-all');
    return mapResult(res, (_) {});
  }
}
