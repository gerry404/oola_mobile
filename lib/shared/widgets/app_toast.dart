import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

/// Petit toast homogene (SnackBar stylisee).
void showToast(BuildContext context, String message, {bool success = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      backgroundColor: success ? AppColors.mint : AppColors.ink,
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
