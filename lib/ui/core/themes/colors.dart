import 'package:flutter/material.dart';

/// Palette de marque OOLA. Design flat, un seul orange.
abstract final class AppColors {
  static const orange = Color(0xFFFF6A00);
  static const orangeDark = Color(0xFFE85D00);
  static const ink = Color(0xFF1C1B1B);
  static const inkSoft = Color(0xFF6B6A6A);
  static const cream = Color(0xFFFDF8F8);
  static const mint = Color(0xFF10B981);
  static const danger = Color(0xFFE11D48);
  static const warning = Color(0xFFF59E0B);

  static const grey1 = Color(0xFFF3F1F1);
  static const grey2 = Color(0xFFE6E3E3);
  static const grey3 = Color(0xFFCFCACA);
  static const white = Color(0xFFFFFFFF);

  static const lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: orange,
    onPrimary: white,
    secondary: ink,
    onSecondary: white,
    surface: white,
    onSurface: ink,
    error: danger,
    onError: white,
  );

  static const darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: orange,
    onPrimary: white,
    secondary: white,
    onSecondary: ink,
    surface: Color(0xFF161515),
    onSurface: Color(0xFFF3F1F1),
    error: danger,
    onError: white,
  );
}
