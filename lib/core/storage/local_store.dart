import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Stockage local non sensible (Hive) : panier, favoris, cache hors ligne.
///
/// Les donnees sensibles (token) restent dans [SecureStore]. Ici on stocke des
/// donnees fonctionnelles pour l'usage hors ligne (cahier des charges §6.2).
class LocalStore {
  LocalStore(this._box);

  final Box _box;

  static const boxName = 'oola_local';

  /// A appeler une fois au demarrage (avant runApp).
  static Future<LocalStore> open() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(boxName);
    return LocalStore(box);
  }

  // ----- Generique JSON -----
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

  Map<String, dynamic>? readMap(String key) {
    final raw = _box.get(key);
    if (raw is! String || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    return null;
  }

  Future<void> writeMap(String key, Map<String, dynamic> value) =>
      _box.put(key, jsonEncode(value));

  Future<void> delete(String key) => _box.delete(key);

  // ----- Onboarding (1er lancement) -----
  static const _kOnboardingSeen = 'onboarding_seen';

  bool get onboardingSeen => _box.get(_kOnboardingSeen) == true;

  Future<void> markOnboardingSeen() => _box.put(_kOnboardingSeen, true);
}
