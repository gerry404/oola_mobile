import 'package:flutter/material.dart';

/// Dimensions responsives (mobile / large), a la maniere du sample compass_app.
abstract final class Dimens {
  const Dimens();

  static const paddingHorizontal = 16.0;
  static const paddingVertical = 16.0;
  static const radius = 14.0;
  static const radiusLarge = 18.0;

  /// Rayons dedies : boutons et champs bien arrondis, hauteur de contrôle
  /// confortable pour le tactile.
  static const radiusButton = 16.0;
  static const radiusField = 16.0;
  static const controlHeight = 54.0;

  double get paddingScreenHorizontal;
  double get paddingScreenVertical;

  EdgeInsets get edgeInsetsScreenHorizontal =>
      EdgeInsets.symmetric(horizontal: paddingScreenHorizontal);

  EdgeInsets get edgeInsetsScreenSymmetric => EdgeInsets.symmetric(
        horizontal: paddingScreenHorizontal,
        vertical: paddingScreenVertical,
      );

  static const Dimens mobile = _DimensMobile();
  static const Dimens large = _DimensLarge();

  factory Dimens.of(BuildContext context) =>
      MediaQuery.sizeOf(context).width > 600 ? large : mobile;
}

final class _DimensMobile extends Dimens {
  const _DimensMobile();
  @override
  final double paddingScreenHorizontal = Dimens.paddingHorizontal;
  @override
  final double paddingScreenVertical = Dimens.paddingVertical;
}

final class _DimensLarge extends Dimens {
  const _DimensLarge();
  @override
  final double paddingScreenHorizontal = 64.0;
  @override
  final double paddingScreenVertical = 32.0;
}
