import '../../utils/parse.dart';

/// Roles de la plateforme (alignes sur le backend Laravel).
enum UserRole {
  client,
  vendor,
  delivery,
  admin,
  unknown;

  static UserRole parse(String? v) => switch (v) {
        'client' => client,
        'vendor' => vendor,
        'delivery' => delivery,
        'admin' => admin,
        _ => unknown,
      };

  bool get isClient => this == client;
  bool get isVendor => this == vendor;
  bool get isDelivery => this == delivery;
  bool get isAdmin => this == admin;
  bool get isPrivileged => isVendor || isDelivery || isAdmin;
}

class UserShop {
  const UserShop({required this.id, this.name, this.slug, this.logoUrl});

  final int id;
  final String? name;
  final String? slug;
  final String? logoUrl;

  factory UserShop.fromJson(Map<String, dynamic> json) => UserShop(
        id: asInt(json['id']),
        name: asStringOrNull(json['name']),
        slug: asStringOrNull(json['slug']),
        logoUrl: asStringOrNull(json['logo_url']),
      );
}

class User {
  const User({
    required this.id,
    required this.name,
    required this.role,
    this.email,
    this.phone,
    this.shop,
  });

  final int id;
  final String name;
  final UserRole role;
  final String? email;
  final String? phone;
  final UserShop? shop;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: asInt(json['id']),
        name: asString(json['name']),
        role: UserRole.parse(asStringOrNull(json['role'])),
        email: asStringOrNull(json['email']),
        phone: asStringOrNull(json['phone']),
        shop: json['shop'] is Map ? UserShop.fromJson(asMap(json['shop'])) : null,
      );
}
