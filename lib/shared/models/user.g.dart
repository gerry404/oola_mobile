// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserShopImpl _$$UserShopImplFromJson(Map<String, dynamic> json) =>
    _$UserShopImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      logoUrl: json['logo_url'] as String?,
    );

Map<String, dynamic> _$$UserShopImplToJson(_$UserShopImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'slug': instance.slug,
      'logo_url': instance.logoUrl,
    };

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  role: $enumDecode(
    _$UserRoleEnumMap,
    json['role'],
    unknownValue: UserRole.unknown,
  ),
  email: json['email'] as String?,
  phone: json['phone'] as String?,
  shop: json['shop'] == null
      ? null
      : UserShop.fromJson(json['shop'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'role': _$UserRoleEnumMap[instance.role]!,
      'email': instance.email,
      'phone': instance.phone,
      'shop': instance.shop,
    };

const _$UserRoleEnumMap = {
  UserRole.client: 'client',
  UserRole.vendor: 'vendor',
  UserRole.delivery: 'delivery',
  UserRole.admin: 'admin',
  UserRole.unknown: 'unknown',
};
