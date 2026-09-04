import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Stockage local non sensible (Hive) : panier, favoris, onboarding, cache.
class LocalStoreService {
  LocalStoreService(this._box);

  final Box _box;

  static const _boxName = 'oola_local';

  /// A ouvrir une fois au demarrage.
  static Future<LocalStoreService> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(_boxName);
    return LocalStoreService(box);
  }

  List<Map<String, dynamic>> readList(String key) {
    final raw = _box.get(key);
    if (raw is! String || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) =>
      _box.put(key, jsonEncode(value));

  bool get onboardingSeen => _box.get('onboarding_seen') == true;
  Future<void> markOnboardingSeen() => _box.put('onboarding_seen', true);
}
