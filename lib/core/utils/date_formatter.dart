import 'package:intl/intl.dart';

/// Handles all date formatting throughout the app.
/// Never format dates directly in widgets.
/// Always use this class.
class DateFormatter {
  // Private constructor to prevent instantiation
  DateFormatter._();

  // ─── Formatters ──────────────────────────────────────────────
  static final _dayMonthYear = DateFormat('dd MMM yyyy');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _dayMonth = DateFormat('dd MMM');
  static final _fullDate = DateFormat('EEEE, dd MMMM yyyy');
  static final _time = DateFormat('hh:mm a');
  static final _dayMonthYearTime = DateFormat('dd MMM yyyy, hh:mm a');
  static final _isoDate = DateFormat('yyyy-MM-dd');
  static final _monthShort = DateFormat('MMM');
  static final _dayShort = DateFormat('EEE');
  static final _month = DateFormat('MMMM');
  static final _year = DateFormat('yyyy');

  /// Formats a date as "12 Jan 2025"
  static String formatDate(DateTime date) {
    return _dayMonthYear.format(date);
  }

  /// Formats a date as "Jan 2025"
  static String formatMonthYear(DateTime date) {
    return _monthYear.format(date);
  }

  /// Formats a date as "12 Jan"
  static String formatDayMonth(DateTime date) {
    return _dayMonth.format(date);
  }

  /// Formats a date as "Monday, 12 January 2025"
  static String formatFullDate(DateTime date) {
    return _fullDate.format(date);
  }

  /// Formats a time as "02:30 PM"
  static String formatTime(DateTime date) {
    return _time.format(date);
  }

  /// Formats a date as "12 Jan 2025, 02:30 PM"
  static String formatDateTime(DateTime date) {
    return _dayMonthYearTime.format(date);
  }

  /// Formats a date as "2025-01-12" (for storage/export)
  static String formatIso(DateTime date) {
    return _isoDate.format(date);
  }

  /// Formats a date as "Jan" (for charts x-axis)
  static String formatMonthShort(DateTime date) {
    return _monthShort.format(date);
  }

  /// Formats a date as "Mon" (for charts x-axis)
  static String formatDayShort(DateTime date) {
    return _dayShort.format(date);
  }

  /// Formats a date as "January"
  static String formatMonth(DateTime date) {
    return _month.format(date);
  }

  /// Formats a date as "2025"
  static String formatYear(DateTime date) {
    return _year.format(date);
  }

  /// Returns a human-readable relative date string.
  ///
  /// Example:
  /// ```dart
  /// DateFormatter.formatRelative(DateTime.now()); // "Today"
  /// DateFormatter.formatRelative(yesterday);       // "Yesterday"
  /// DateFormatter.formatRelative(lastWeek);        // "12 Jan 2025"
  /// ```
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return '$difference days ago';

    return formatDate(date);
  }

  /// Returns the start of the current month.
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// Returns the end of the current month.
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  /// Returns the start of the current week (Monday).
  static DateTime get startOfWeek {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1));
  }

  /// Returns the end of the current week (Sunday).
  static DateTime get endOfWeek {
    final now = DateTime.now();
    return now.add(Duration(days: 7 - now.weekday));
  }

  /// Returns a list of the last [count] months as DateTime objects.
  /// Used for generating chart data points.
  ///
  /// Example:
  /// ```dart
  /// DateFormatter.lastMonths(6); // [Jun, Jul, Aug, Sep, Oct, Nov]
  /// ```
  static List<DateTime> lastMonths(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      return DateTime(now.year, now.month - (count - 1 - index), 1);
    });
  }

  /// Returns a list of the last [count] weeks as DateTime objects.
  static List<DateTime> lastWeeks(int count) {
    final now = DateTime.now();
    return List.generate(count, (index) {
      return now.subtract(Duration(days: (count - 1 - index) * 7));
    });
  }

  /// Checks if two dates are on the same day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Checks if two dates are in the same month.
  static bool isSameMonth(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month;
  }
}
