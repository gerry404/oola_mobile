import 'package:flutter/material.dart';

/// Transitions d'ecran de l'application.
///
/// Plutot qu'une seule animation partout, on adapte :
///  - Defaut de plateforme : zoom Material (Android, predictive back) / glissement
///    Cupertino (iOS), via [pageTransitionsTheme].
///  - Routes explicites : [modalRoute] (glissement vertical, pour un contenu
///    "feuille" comme la fiche produit ou le paiement) et [fadeRoute].
abstract final class AppTransitions {
  /// Theme applique a toutes les MaterialPageRoute.
  static const PageTransitionsTheme pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: ZoomPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    },
  );

  /// Route "modale" : le contenu monte depuis le bas avec un fondu.
  /// Convient aux ecrans qu'on "ouvre" par-dessus (fiche produit, paiement).
  static Route<T> modalRoute<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  /// Route en fondu simple (ecrans "de meme niveau", ex. changement de contexte).
  static Route<T> fadeRoute<T>(Widget page, {String? name}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: name),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
