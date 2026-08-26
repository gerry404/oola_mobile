/// Helpers de parsing defensif pour les reponses JSON de l'API.
///
/// L'API peut renvoyer des nombres en string, des null la ou on attend 0, etc.
/// Ces helpers evitent de repeter les casts et rendent le mapping robuste.
library;

int asInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt() ?? fallback;
  return fallback;
}

int? asIntOrNull(dynamic v) {
  if (v == null) return null;
  return asInt(v);
}

double asDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? fallback;
  return fallback;
}

String asString(dynamic v, [String fallback = '']) {
  if (v is String) return v;
  if (v == null) return fallback;
  return v.toString();
}

String? asStringOrNull(dynamic v) {
  if (v == null) return null;
  final s = v is String ? v : v.toString();
  return s.isEmpty ? null : s;
}

bool asBool(dynamic v, [bool fallback = false]) {
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return fallback;
}

DateTime? asDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

/// Convertit une valeur en `Map<String, dynamic>` sans planter.
Map<String, dynamic> asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return const {};
}

/// Convertit une valeur en `List<dynamic>`.
List<dynamic> asList(dynamic v) {
  if (v is List) return v;
  return const [];
}
