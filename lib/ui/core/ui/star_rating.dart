import 'package:flutter/material.dart';

import '../themes/colors.dart';

/// Note en etoiles (lecture seule).
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, this.count, this.size = 16});

  final double value;
  final int? count;
  final double size;

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
            color: AppColors.warning,
          ),
        if (count != null) ...[
          const SizedBox(width: 6),
          Text('($count)',
              style: TextStyle(fontSize: size * 0.8, color: AppColors.inkSoft)),
        ],
      ],
    );
  }
}
