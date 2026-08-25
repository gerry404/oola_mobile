import 'package:flutter/material.dart';

/// Logo OOLA (monogramme officiel). Transparent, marche sur fond clair/sombre.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/oola-mark.png',
      height: size,
      fit: BoxFit.contain,
      // Repli discret si l'asset manque au premier lancement.
      errorBuilder: (_, __, ___) => Text(
        'OOLA',
        style: TextStyle(
          fontSize: size * 0.5,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFF6A00),
        ),
      ),
    );
  }
}
