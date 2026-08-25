import 'package:flutter/material.dart';

/// Palette de marque OOLA (alignee sur les tokens du site web).
/// Design flat, un seul orange, pas de degrade.
abstract final class AppColors {
  // Marque
  static const orange = Color(0xFFFF6A00);
  static const orangeDark = Color(0xFFE85D00);
  static const ink = Color(0xFF1C1B1B);
  static const inkSoft = Color(0xFF6B6A6A);
  static const cream = Color(0xFFFDF8F8);
  static const mint = Color(0xFF10B981);

  // Gris
  static const gray100 = Color(0xFFF3F1F1);
  static const gray200 = Color(0xFFE6E3E3);
  static const gray300 = Color(0xFFCFCACA);

  // Etats
  static const danger = Color(0xFFE11D48);
  static const warning = Color(0xFFF59E0B);
  static const success = mint;

  static const white = Color(0xFFFFFFFF);
}
