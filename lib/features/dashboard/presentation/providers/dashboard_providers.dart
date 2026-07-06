import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/presentation/providers/transaction_providers.dart';

/// Represents a single slice in the spending pie chart.
class CategorySpending {
  final String categoryName;
  final int colorValue;
  final int iconCode;
  final double amount;
  final double percentage;

  const CategorySpending({
    required this.categoryName,
    required this.colorValue,
    required this.iconCode,
    required this.amount,
    required this.percentage,
  });
}

/// Represents a single bar in the weekly spending chart.
class DailySpending {
  final String dayLabel;
  final double amount;

  const DailySpending({required this.dayLabel, required this.amount});
}

/// Provides spending breakdown by category for the pie chart.
///
/// Only shows expense categories.
/// Automatically recalculates when transactions change.
///
/// Usage:
/// ```dart
/// final spendingAsync = ref.watch(categorySpendingProvider);
/// ```
final categorySpendingProvider = Provider<AsyncValue<List<CategorySpending>>>((
  ref,
) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData((transactions) {
    // Filter only expenses
    final expenses = transactions.where((t) => t.type.isExpense).toList();

    if (expenses.isEmpty) return [];

    // Calculate total expenses
    final totalExpenses = expenses.fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );

    // Group by category
    final Map<String, Map<String, dynamic>> grouped = {};

    for (final transaction in expenses) {
      final categoryId = transaction.category.id;

      if (grouped.containsKey(categoryId)) {
        grouped[categoryId]!['amount'] =
            (grouped[categoryId]!['amount'] as double) + transaction.amount;
      } else {
        grouped[categoryId] = {
          'name': transaction.category.name,
          'colorValue': transaction.category.colorValue,
          'iconCode': transaction.category.iconCode,
          'amount': transaction.amount,
        };
      }
    }

    // Convert to CategorySpending list
    final result =
        grouped.entries.map((entry) {
          final data = entry.value;
          final amount = data['amount'] as double;

          return CategorySpending(
            categoryName: data['name'] as String,
            colorValue: data['colorValue'] as int,
            iconCode: data['iconCode'] as int,
            amount: amount,
            percentage: (amount / totalExpenses) * 100,
          );
        }).toList();

    // Sort by amount (highest first)
    result.sort((a, b) => b.amount.compareTo(a.amount));

    return result;
  });
});

/// Provides daily spending data for the current week.
///
/// Returns 7 entries (Mon to Sun) with the total expense for each day.
/// Used for the weekly bar chart.
///
/// Usage:
/// ```dart
/// final weeklyAsync = ref.watch(weeklySpendingProvider);
/// ```
final weeklySpendingProvider = Provider<AsyncValue<List<DailySpending>>>((ref) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData((transactions) {
    final now = DateTime.now();

    // Find the start of the current week (Monday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (index) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      );

      // Sum expenses for this day
      final dayExpenses = transactions
          .where(
            (t) =>
                t.type.isExpense &&
                t.date.year == day.year &&
                t.date.month == day.month &&
                t.date.day == day.day,
          )
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      return DailySpending(dayLabel: dayLabels[index], amount: dayExpenses);
    });
  });
});

/// Provides a greeting message based on the time of day.
///
/// Usage:
/// ```dart
/// final greeting = ref.watch(greetingProvider);
/// ```
final greetingProvider = Provider<String>((ref) {
  final hour = DateTime.now().hour;

  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  if (hour < 21) return 'Good Evening';
  return 'Good Night';
});
