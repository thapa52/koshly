import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/use_cases/add_transaction.dart';
import '../../domain/use_cases/delete_transaction.dart';
import '../../domain/use_cases/get_transaction_summary.dart';
import '../../domain/use_cases/get_transactions.dart';
import '../../domain/use_cases/update_transaction.dart';
import 'repository_provider.dart';

/// Manages the state of all transactions.
///
/// Automatically loads transactions from Hive on first access.
/// All CRUD operations go through domain use cases.
///
/// Usage in widgets:
/// ```dart
/// final transactionsAsync = ref.watch(transactionNotifierProvider);
/// transactionsAsync.when(
///   data: (transactions) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
class TransactionNotifier extends AsyncNotifier<List<Transaction>> {
  /// Use cases — initialized in build()
  late final GetTransactions _getTransactions;
  late final AddTransaction _addTransaction;
  late final UpdateTransaction _updateTransaction;
  late final DeleteTransaction _deleteTransaction;

  @override
  FutureOr<List<Transaction>> build() async {
    final repository = ref.read(transactionRepositoryProvider);

    // Initialize use cases with the repository
    _getTransactions = GetTransactions(repository);
    _addTransaction = AddTransaction(repository);
    _updateTransaction = UpdateTransaction(repository);
    _deleteTransaction = DeleteTransaction(repository);

    return _getTransactions.all();
  }

  /// Adds a new transaction.
  ///
  /// The use case validates the data before saving.
  /// Refreshes the transaction list after saving.
  Future<void> addTransaction(Transaction transaction) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _addTransaction.call(transaction);
      return _getTransactions.all();
    });
  }

  /// Updates an existing transaction.
  ///
  /// The use case validates the updated data before saving.
  /// Refreshes the transaction list after saving.
  Future<void> updateTransaction(Transaction transaction) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _updateTransaction.call(transaction);
      return _getTransactions.all();
    });
  }

  /// Deletes a transaction by ID.
  ///
  /// Refreshes the transaction list after deletion.
  Future<void> deleteTransaction(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _deleteTransaction.call(id);
      return _getTransactions.all();
    });
  }

  /// Returns transactions filtered by type.
  Future<List<Transaction>> getByType(TransactionType type) async {
    return _getTransactions.byType(type);
  }

  /// Returns transactions within a date range.
  Future<List<Transaction>> getByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _getTransactions.byDateRange(startDate: startDate, endDate: endDate);
  }
}

/// Provider for [TransactionNotifier].
final transactionNotifierProvider =
    AsyncNotifierProvider<TransactionNotifier, List<Transaction>>(
      TransactionNotifier.new,
    );

// ─── Derived Providers ──────────────────────────────────────────

/// Provides transaction summary (total income, expenses, balance).
///
/// Automatically recalculates when transactions change.
///
/// Usage:
/// ```dart
/// final summaryAsync = ref.watch(transactionSummaryProvider);
/// summaryAsync.when(
///   data: (summary) => Text('Balance: ${summary.balance}'),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error'),
/// );
/// ```
final transactionSummaryProvider = FutureProvider<TransactionSummary>((
  ref,
) async {
  // Watch transactions so summary recalculates when list changes
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  // Only calculate when transactions are loaded
  return transactionsAsync.when(
    data: (transactions) {
      final income = transactions
          .where((t) => t.type.isIncome)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      final expenses = transactions
          .where((t) => t.type.isExpense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);

      return TransactionSummary(
        totalIncome: income,
        totalExpenses: expenses,
        balance: income - expenses,
        transactionCount: transactions.length,
      );
    },
    loading: () => throw Exception('Transactions still loading'),
    error: (e, st) => throw e,
  );
});

/// Provides only income transactions.
///
/// Automatically updates when the main list changes.
final incomeTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData(
    (transactions) => transactions.where((t) => t.type.isIncome).toList(),
  );
});

/// Provides only expense transactions.
///
/// Automatically updates when the main list changes.
final expenseTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData(
    (transactions) => transactions.where((t) => t.type.isExpense).toList(),
  );
});

/// Provides recent transactions (last 5).
///
/// Used on the dashboard for a quick overview.
final recentTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData(
    (transactions) => transactions.take(5).toList(),
  );
});
