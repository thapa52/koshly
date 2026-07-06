import 'package:koshly/features/transactions/domain/entities/category.dart';
import 'package:koshly/features/transactions/domain/entities/transaction.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';
import 'package:koshly/features/transactions/domain/repositories/transaction_repository.dart';

/// A fake implementation of [TransactionRepository] for testing.
///
/// Stores data in memory using simple lists.
/// Behaves like a real repository but without Hive dependency.
///
/// Usage in tests:
/// ```dart
/// final repository = FakeTransactionRepository();
/// final useCase = AddTransaction(repository);
/// ```
class FakeTransactionRepository implements TransactionRepository {
  /// In-memory storage for transactions
  final List<Transaction> _transactions = [];

  /// In-memory storage for categories
  final List<Category> _categories = [];

  /// Provides read access to stored transactions for test assertions.
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  /// Provides read access to stored categories for test assertions.
  List<Category> get categories => List.unmodifiable(_categories);

  /// Seed test categories for convenience.
  void seedCategories(List<Category> categories) {
    _categories.addAll(categories);
  }

  /// Seed test transactions for convenience.
  void seedTransactions(List<Transaction> transactions) {
    _transactions.addAll(transactions);
  }

  /// Clears all stored data. Call in setUp() or tearDown().
  void reset() {
    _transactions.clear();
    _categories.clear();
  }

  // ─── Transaction Operations ──────────────────────────────────

  @override
  Future<List<Transaction>> getAllTransactions() async {
    final sorted = List<Transaction>.from(_transactions);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final filtered =
        _transactions.where((t) {
          return t.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
              t.date.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    final filtered =
        _transactions.where((t) => t.category.id == categoryId).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    final filtered = _transactions.where((t) => t.type == type).toList();

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction;
    }
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
  }

  @override
  Future<double> getTotalIncome({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions =
        startDate != null && endDate != null
            ? await getTransactionsByDateRange(
              startDate: startDate,
              endDate: endDate,
            )
            : await getAllTransactions();

    return transactions
        .where((t) => t.type.isIncome)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final transactions =
        startDate != null && endDate != null
            ? await getTransactionsByDateRange(
              startDate: startDate,
              endDate: endDate,
            )
            : await getAllTransactions();

    return transactions
        .where((t) => t.type.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getBalance({DateTime? startDate, DateTime? endDate}) async {
    final income = await getTotalIncome(startDate: startDate, endDate: endDate);
    final expenses = await getTotalExpenses(
      startDate: startDate,
      endDate: endDate,
    );
    return income - expenses;
  }

  // ─── Category Operations ──────────────────────────────────────

  @override
  Future<List<Category>> getAllCategories() async {
    return List.unmodifiable(_categories);
  }

  @override
  Future<List<Category>> getCategoriesByType(TransactionType type) async {
    return _categories.where((c) => c.type == type).toList();
  }

  @override
  Future<Category> addCategory(Category category) async {
    _categories.add(category);
    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
    }
    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    final category = _categories.firstWhere((c) => c.id == id);
    if (category.isDefault) {
      throw ArgumentError('Cannot delete default categories.');
    }
    _categories.removeWhere((c) => c.id == id);
  }
}
