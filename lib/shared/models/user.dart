import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Roles de la plateforme OOLAshop (alignes sur le backend Laravel).
enum UserRole {
  @JsonValue('client')
  client,
  @JsonValue('vendor')
  vendor,
  @JsonValue('delivery')
  delivery,
  @JsonValue('admin')
  admin,
  @JsonValue('unknown')
  unknown;

  bool get isClient => this == UserRole.client;
  bool get isVendor => this == UserRole.vendor;
  bool get isDelivery => this == UserRole.delivery;
  bool get isAdmin => this == UserRole.admin;
}

/// Boutique liee a un compte vendeur (charge partiellement selon l'endpoint).
@freezed
class UserShop with _$UserShop {
  const factory UserShop({
    required int id,
    String? name,
    String? slug,
    @JsonKey(name: 'logo_url') String? logoUrl,
  }) = _UserShop;

  factory UserShop.fromJson(Map<String, dynamic> json) =>
      _$UserShopFromJson(json);
}

/// Utilisateur connecte.
@freezed
class User with _$User {
  const factory User({
    required int id,
    required String name,
    @JsonKey(unknownEnumValue: UserRole.unknown) required UserRole role,
    String? email,
    String? phone,
    UserShop? shop,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
