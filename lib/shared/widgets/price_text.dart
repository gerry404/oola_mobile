import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../core/utils/formatters.dart';

/// Affiche un prix en FCFA, avec prix barre optionnel si promo.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.original,
    this.color = AppColors.ink,
    this.size = 16,
    this.onLight = false,
  });

  /// Prix a payer.
  final int price;

  /// Prix d'origine (barre) si different et superieur.
  final int? original;
  final Color color;
  final double size;

  /// true si affiche sur fond sombre (vidéo) : force le blanc.
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final showStrike = original != null && original! > price;
    final main = onLight ? Colors.white : color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          formatCFA(price),
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w800,
            color: showStrike ? (onLight ? Colors.white : AppColors.orange) : main,
          ),
        ),
        if (showStrike) ...[
          const SizedBox(width: 6),
          Text(
            formatCFA(original!),
            style: TextStyle(
              fontSize: size * 0.72,
              decoration: TextDecoration.lineThrough,
              color: (onLight ? Colors.white : AppColors.inkSoft).withValues(alpha: 0.7),
            ),
          ),
        ],
      ],
    );
  }
}
