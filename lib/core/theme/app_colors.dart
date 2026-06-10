import 'package:flutter/material.dart';

/// All colors used in the app.
/// Never use hardcoded colors in widgets.
/// Always reference from AppColors.
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ─── Brand Colors ────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);
  static const Color primaryLight = Color(0xFF9C94FF);
  static const Color primaryDark = Color(0xFF3D35CC);

  // ─── Semantic Colors ─────────────────────────────────────────
  static const Color income = Color(0xFF2ECC71);
  static const Color incomeLight = Color(0xFFD5F5E3);
  static const Color expense = Color(0xFFE74C3C);
  static const Color expenseLight = Color(0xFFFDEDEC);
  static const Color savings = Color(0xFF3498DB);
  static const Color savingsLight = Color(0xFFD6EAF8);
  static const Color warning = Color(0xFFF39C12);
  static const Color warningLight = Color(0xFFFEF9E7);
  static const Color success = Color(0xFF27AE60);
  static const Color error = Color(0xFFC0392B);

  // ─── Light Theme Colors ──────────────────────────────────────
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCardBackground = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightBorder = Color(0xFFE5E7EB);

  // ─── Dark Theme Colors ───────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F0F1A);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkCardBackground = Color(0xFF16213E);
  static const Color darkTextPrimary = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextHint = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF2D2D44);
  static const Color darkBorder = Color(0xFF2D2D44);

  // ─── Category Colors ─────────────────────────────────────────
  // Used for transaction categories
  static const List<Color> categoryColors = [
    Color(0xFF6C63FF), // Purple
    Color(0xFF2ECC71), // Green
    Color(0xFFE74C3C), // Red
    Color(0xFF3498DB), // Blue
    Color(0xFFF39C12), // Orange
    Color(0xFF9B59B6), // Violet
    Color(0xFF1ABC9C), // Teal
    Color(0xFFE67E22), // Dark Orange
    Color(0xFF34495E), // Dark Blue Grey
    Color(0xFFE91E63), // Pink
    Color(0xFF00BCD4), // Cyan
    Color(0xFF8BC34A), // Light Green
  ];

  // ─── Chart Colors ────────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF6C63FF),
    Color(0xFF2ECC71),
    Color(0xFFE74C3C),
    Color(0xFF3498DB),
    Color(0xFFF39C12),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
  ];
}
