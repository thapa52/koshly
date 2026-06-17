import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../repositories/transaction_repository.dart';

/// Use case to retrieve transactions from the repository.
///
/// Supports multiple query methods:
/// - Get all transactions
/// - Get transactions by date range
/// - Get transactions by category
/// - Get transactions by type
class GetTransactions {
  final TransactionRepository _repository;

  const GetTransactions(this._repository);

  /// Returns all transactions sorted by date (newest first).
  Future<List<Transaction>> all() async {
    return _repository.getAllTransactions();
  }

  /// Returns transactions within a specific date range.
  ///
  /// Example:
  /// ```dart
  /// final monthly = await getTransactions.byDateRange(
  ///   startDate: DateTime(2025, 1, 1),
  ///   endDate: DateTime(2025, 1, 31),
  /// );
  /// ```
  Future<List<Transaction>> byDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return _repository.getTransactionsByDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Returns transactions for a specific category.
  Future<List<Transaction>> byCategory(String categoryId) async {
    return _repository.getTransactionsByCategory(categoryId);
  }

  /// Returns transactions of a specific type (income or expense).
  Future<List<Transaction>> byType(TransactionType type) async {
    return _repository.getTransactionsByType(type);
  }
}
