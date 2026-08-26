import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Affiche une note en etoiles (lecture seule) avec compte optionnel.
class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.value,
    this.count,
    this.size = 16,
    this.color = AppColors.warning,
  });

  final double value;
  final int? count;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i
                ? Icons.star
                : (value >= i - 0.5 ? Icons.star_half : Icons.star_border),
            size: size,
            color: color,
          ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Text(
            '($count)',
            style: TextStyle(fontSize: size * 0.8, color: AppColors.inkSoft),
          ),
        ],
      ],
    );
  }
}

/// Etoiles interactives pour saisir une note.
class StarInput extends StatelessWidget {
  const StarInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 34,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => onChanged(i),
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(),
            icon: Icon(
              value >= i ? Icons.star : Icons.star_border,
              size: size,
              color: AppColors.warning,
            ),
          ),
      ],
    );
  }
}
