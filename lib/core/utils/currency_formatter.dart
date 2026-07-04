import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

/// Handles all currency formatting throughout the app.
/// Never format currency directly in widgets.
/// Always use this class.
class CurrencyFormatter {
  // Private constructor to prevent instantiation
  CurrencyFormatter._();

  /// Formats a double amount into a currency string.
  ///
  /// Example:
  /// ```dart
  /// CurrencyFormatter.format(1234.56); // "$1,234.56"
  /// CurrencyFormatter.format(1234.56, symbol: '£'); // "£1,234.56"
  /// ```
  static String format(
    double amount, {
    String? symbol,
    String? locale,
    bool showSign = false,
  }) {
    final currencySymbol = symbol ?? AppConstants.defaultCurrencySymbol;

    final formatter = NumberFormat.currency(
      locale: locale ?? 'en_US',
      symbol: currencySymbol,
      decimalDigits: 2,
    );

    if (showSign && amount > 0) {
      return '+${formatter.format(amount)}';
    }

    return formatter.format(amount);
  }

  /// Formats a double amount into a compact string.
  /// Used when space is limited (e.g., charts).
  ///
  /// Example:
  /// ```dart
  /// CurrencyFormatter.formatCompact(1234567.89); // "$1.2M"
  /// CurrencyFormatter.formatCompact(1234.56);    // "$1.2K"
  /// ```
  static String formatCompact(double amount, {String? symbol}) {
    final currencySymbol = symbol ?? AppConstants.defaultCurrencySymbol;

    final formatter = NumberFormat.compactCurrency(
      locale: 'en_US',
      symbol: currencySymbol,
      decimalDigits: 1,
    );

    return formatter.format(amount);
  }

  /// Formats a double amount without currency symbol.
  /// Used when the symbol is displayed separately.
  ///
  /// Example:
  /// ```dart
  /// CurrencyFormatter.formatAmount(1234.56); // "1,234.56"
  /// ```
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  /// Returns the absolute value formatted as currency.
  /// Useful for displaying expense amounts without negative sign.
  ///
  /// Example:
  /// ```dart
  /// CurrencyFormatter.formatAbsolute(-1234.56); // "$1,234.56"
  /// ```
  static String formatAbsolute(double amount, {String? symbol}) {
    return format(amount.abs(), symbol: symbol);
  }

  /// Parses a currency string back to a double.
  ///
  /// Example:
  /// ```dart
  /// CurrencyFormatter.parse('\$1,234.56'); // 1234.56
  /// ```
  static double parse(String value) {
    // Remove all non-numeric characters except decimal point
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
