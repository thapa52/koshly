/// App-wide constant values.
/// Never hardcode these values directly in widgets or repositories.
/// Always reference them from here.
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ─── App Info ───────────────────────────────────────────────
  static const String appName = 'Koshly';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Your Personal Treasury';

  // ─── Hive Box Names ───────────────────────────────────────────────
  // These are the names of the Hive boxes (like table names in SQL)
  static const String transactionBox = 'transactions';
  static const String categoryBox = 'categories';
  static const String savingsBox = 'savings_goals';
  static const String settingsBox = 'settings';

  // ─── Hive Type IDs ──────────────────────────────────────────
  // Every Hive model needs a unique type ID for code generation
  // We define them here to avoid accidental duplicates
  static const int transactionTypeId = 0;
  static const int categoryTypeId = 1;
  static const int savingsGoalTypeId = 2;
  static const int transactionTypeEnumId = 3;

  // ─── SharedPreferences Keys ──────────────────────────────────
  static const String prefThemeMode = 'theme_mode';
  static const String prefCurrency = 'currency';
  static const String prefOnboardingComplete = 'onboarding_complete';

  // ─── Default Values ──────────────────────────────────────────
  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';

  // ─── Supported Currencies ────────────────────────────────────
  static const List<Map<String, String>> supportedCurrencies = [
    {'code': 'USD', 'symbol': '\$', 'name': 'US Dollar'},
    {'code': 'EUR', 'symbol': '€', 'name': 'Euro'},
    {'code': 'GBP', 'symbol': '£', 'name': 'British Pound'},
    {'code': 'NPR', 'symbol': 'Rs', 'name': 'Nepali Rupee'},
    {'code': 'INR', 'symbol': '₹', 'name': 'Indian Rupee'},
    {'code': 'JPY', 'symbol': '¥', 'name': 'Japanese Yen'},
    {'code': 'AUD', 'symbol': 'A\$', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'symbol': 'C\$', 'name': 'Canadian Dollar'},
  ];

  // ─── UI Constants ────────────────────────────────────────────
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double largeRadius = 20.0;
  static const double cardElevation = 0.0;

  // ─── Animation Durations ─────────────────────────────────────
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ─── Chart Constants ─────────────────────────────────────────
  static const int chartMaxDataPoints = 7;
  static const double chartBarWidth = 16.0;
  static const double chartHeight = 200.0;
}
