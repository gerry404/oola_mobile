import '../../core/utils/parse.dart';

/// Adresse de livraison enregistree par le client.
class Address {
  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.commune,
    this.street,
    this.details,
    this.isDefault = false,
  });

  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String commune;
  final String? street;
  final String? details;
  final bool isDefault;

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: asInt(json['id']),
        label: asString(json['label']),
        recipientName: asString(json['recipient_name']),
        phone: asString(json['phone']),
        commune: asString(json['commune']),
        street: asStringOrNull(json['street']),
        details: asStringOrNull(json['details']),
        isDefault: asBool(json['is_default']),
      );

  Map<String, dynamic> toPayload() => {
        'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'commune': commune,
        if (street != null) 'street': street,
        if (details != null) 'details': details,
        'is_default': isDefault,
      };
}
