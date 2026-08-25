// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserShop _$UserShopFromJson(Map<String, dynamic> json) {
  return _UserShop.fromJson(json);
}

/// @nodoc
mixin _$UserShop {
  int get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String? get slug => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_url')
  String? get logoUrl => throw _privateConstructorUsedError;

  /// Serializes this UserShop to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserShop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserShopCopyWith<UserShop> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserShopCopyWith<$Res> {
  factory $UserShopCopyWith(UserShop value, $Res Function(UserShop) then) =
      _$UserShopCopyWithImpl<$Res, UserShop>;
  @useResult
  $Res call({
    int id,
    String? name,
    String? slug,
    @JsonKey(name: 'logo_url') String? logoUrl,
  });
}

/// @nodoc
class _$UserShopCopyWithImpl<$Res, $Val extends UserShop>
    implements $UserShopCopyWith<$Res> {
  _$UserShopCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserShop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? slug = freezed,
    Object? logoUrl = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            slug: freezed == slug
                ? _value.slug
                : slug // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoUrl: freezed == logoUrl
                ? _value.logoUrl
                : logoUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserShopImplCopyWith<$Res>
    implements $UserShopCopyWith<$Res> {
  factory _$$UserShopImplCopyWith(
    _$UserShopImpl value,
    $Res Function(_$UserShopImpl) then,
  ) = __$$UserShopImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String? name,
    String? slug,
    @JsonKey(name: 'logo_url') String? logoUrl,
  });
}

/// @nodoc
class __$$UserShopImplCopyWithImpl<$Res>
    extends _$UserShopCopyWithImpl<$Res, _$UserShopImpl>
    implements _$$UserShopImplCopyWith<$Res> {
  __$$UserShopImplCopyWithImpl(
    _$UserShopImpl _value,
    $Res Function(_$UserShopImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserShop
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? slug = freezed,
    Object? logoUrl = freezed,
  }) {
    return _then(
      _$UserShopImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        slug: freezed == slug
            ? _value.slug
            : slug // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoUrl: freezed == logoUrl
            ? _value.logoUrl
            : logoUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserShopImpl implements _UserShop {
  const _$UserShopImpl({
    required this.id,
    this.name,
    this.slug,
    @JsonKey(name: 'logo_url') this.logoUrl,
  });

  factory _$UserShopImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserShopImplFromJson(json);

  @override
  final int id;
  @override
  final String? name;
  @override
  final String? slug;
  @override
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  @override
  String toString() {
    return 'UserShop(id: $id, name: $name, slug: $slug, logoUrl: $logoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserShopImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name, slug, logoUrl);

  /// Create a copy of UserShop
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserShopImplCopyWith<_$UserShopImpl> get copyWith =>
      __$$UserShopImplCopyWithImpl<_$UserShopImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserShopImplToJson(this);
  }
}

abstract class _UserShop implements UserShop {
  const factory _UserShop({
    required final int id,
    final String? name,
    final String? slug,
    @JsonKey(name: 'logo_url') final String? logoUrl,
  }) = _$UserShopImpl;

  factory _UserShop.fromJson(Map<String, dynamic> json) =
      _$UserShopImpl.fromJson;

  @override
  int get id;
  @override
  String? get name;
  @override
  String? get slug;
  @override
  @JsonKey(name: 'logo_url')
  String? get logoUrl;

  /// Create a copy of UserShop
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserShopImplCopyWith<_$UserShopImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(unknownEnumValue: UserRole.unknown)
  UserRole get role => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  UserShop? get shop => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(unknownEnumValue: UserRole.unknown) UserRole role,
    String? email,
    String? phone,
    UserShop? shop,
  });

  $UserShopCopyWith<$Res>? get shop;
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? role = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? shop = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            role: null == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
                      as UserRole,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
            phone: freezed == phone
                ? _value.phone
                : phone // ignore: cast_nullable_to_non_nullable
                      as String?,
            shop: freezed == shop
                ? _value.shop
                : shop // ignore: cast_nullable_to_non_nullable
                      as UserShop?,
          )
          as $Val,
    );
  }

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserShopCopyWith<$Res>? get shop {
    if (_value.shop == null) {
      return null;
    }

    return $UserShopCopyWith<$Res>(_value.shop!, (value) {
      return _then(_value.copyWith(shop: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(unknownEnumValue: UserRole.unknown) UserRole role,
    String? email,
    String? phone,
    UserShop? shop,
  });

  @override
  $UserShopCopyWith<$Res>? get shop;
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? role = null,
    Object? email = freezed,
    Object? phone = freezed,
    Object? shop = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        role: null == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
                  as UserRole,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
        phone: freezed == phone
            ? _value.phone
            : phone // ignore: cast_nullable_to_non_nullable
                  as String?,
        shop: freezed == shop
            ? _value.shop
            : shop // ignore: cast_nullable_to_non_nullable
                  as UserShop?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    required this.id,
    required this.name,
    @JsonKey(unknownEnumValue: UserRole.unknown) required this.role,
    this.email,
    this.phone,
    this.shop,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(unknownEnumValue: UserRole.unknown)
  final UserRole role;
  @override
  final String? email;
  @override
  final String? phone;
  @override
  final UserShop? shop;

  @override
  String toString() {
    return 'User(id: $id, name: $name, role: $role, email: $email, phone: $phone, shop: $shop)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.shop, shop) || other.shop == shop));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, role, email, phone, shop);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    required final int id,
    required final String name,
    @JsonKey(unknownEnumValue: UserRole.unknown) required final UserRole role,
    final String? email,
    final String? phone,
    final UserShop? shop,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(unknownEnumValue: UserRole.unknown)
  UserRole get role;
  @override
  String? get email;
  @override
  String? get phone;
  @override
  UserShop? get shop;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
