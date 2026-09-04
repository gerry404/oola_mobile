import 'package:flutter/material.dart';

import '../themes/colors.dart';

/// Logo OOLA (monogramme officiel, transparent).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/oola-mark.png',
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Text(
        'OOLA',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
          color: AppColors.orange,
        ),
      ),
    );
  }
}
