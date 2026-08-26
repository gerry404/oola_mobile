import 'package:dio/dio.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/models/address.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/models/user.dart';

/// Acces au compte : profil, adresses, notifications.
class AccountRepository {
  AccountRepository(this._dio);
  final Dio _dio;

  Future<User> updateProfile({String? name, String? phone}) async {
    try {
      final res = await _dio.patch('/me', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
      });
      final data = _map(res.data)['data'] ?? res.data;
      return User.fromJson(_map(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> updatePassword({
    required String current,
    required String password,
  }) async {
    try {
      await _dio.post('/me/password', data: {
        'current_password': current,
        'password': password,
        'password_confirmation': password,
      });
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ----- Adresses -----
  Future<List<Address>> addresses() async {
    try {
      final res = await _dio.get('/me/addresses');
      final list = _map(res.data)['data'] ?? [];
      return (list as List).map((e) => Address.fromJson(_map(e))).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Address> createAddress(Address address) async {
    try {
      final res = await _dio.post('/me/addresses', data: address.toPayload());
      return Address.fromJson(_map(_map(res.data)['data'] ?? res.data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Address> updateAddress(int id, Address address) async {
    try {
      final res = await _dio.patch('/me/addresses/$id', data: address.toPayload());
      return Address.fromJson(_map(_map(res.data)['data'] ?? res.data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> deleteAddress(int id) async {
    try {
      await _dio.delete('/me/addresses/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  // ----- Notifications -----
  Future<List<AppNotification>> notifications() async {
    try {
      final res = await _dio.get('/me/notifications');
      final data = _map(res.data)['data'];
      final list = data is Map ? (data['data'] ?? []) : (data ?? []);
      return (list as List).map((e) => AppNotification.fromJson(_map(e))).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<int> unreadCount() async {
    try {
      final res = await _dio.get('/me/notifications/unread-count');
      final m = _map(res.data);
      return (m['count'] ?? m['unread_count'] ?? 0) as int;
    } on DioException catch (_) {
      return 0;
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.post('/me/notifications/read-all');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Map<String, dynamic> _map(dynamic v) =>
      v is Map<String, dynamic> ? v : Map<String, dynamic>.from(v as Map);
}
