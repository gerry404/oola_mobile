import '../../utils/parse.dart';

/// Zone de livraison : communes partageant un tarif (FCFA).
class DeliveryZone {
  const DeliveryZone({
    required this.id,
    required this.code,
    required this.label,
    required this.communes,
    required this.fee,
  });

  final int id;
  final String code;
  final String label;
  final List<String> communes;
  final int fee;

  factory DeliveryZone.fromJson(Map<String, dynamic> json) => DeliveryZone(
        id: asInt(json['id']),
        code: asString(json['code']),
        label: asString(json['label']),
        communes: asList(json['communes']).map((e) => e.toString()).toList(),
        fee: asInt(json['fee']),
      );
}
