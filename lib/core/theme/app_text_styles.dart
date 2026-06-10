import 'package:flutter/material.dart';

import 'app_colors.dart';

/// All text styles used in the app.
/// Never use hardcoded TextStyle in widgets.
/// Always reference from AppTextStyles.
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  // ─── Display Styles ──────────────────────────────────────────
  // Used for large numbers like total balance
  static const TextStyle displayLarge = TextStyle(
    fontSize: 40.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
  );

  // ─── Headline Styles ─────────────────────────────────────────
  // Used for screen titles and section headers
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  // ─── Body Styles ─────────────────────────────────────────────
  // Used for regular content
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.1,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    height: 1.5,
  );

  // ─── Label Styles ────────────────────────────────────────────
  // Used for buttons, chips, and small labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
    height: 1.4,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.4,
  );

  // ─── Amount Styles ───────────────────────────────────────────
  // Used specifically for displaying money amounts
  static const TextStyle amountLarge = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountMedium = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
    height: 1.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle amountSmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.4,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // ─── Colored Amount Styles ───────────────────────────────────
  static TextStyle get incomeAmount =>
      amountMedium.copyWith(color: AppColors.income);

  static TextStyle get expenseAmount =>
      amountMedium.copyWith(color: AppColors.expense);
}
