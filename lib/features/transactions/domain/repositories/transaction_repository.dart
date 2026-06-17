import '../entities/category.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';

/// Abstract interface for transaction data operations.
///
/// The domain layer depends on this interface.
/// The data layer implements this interface.
///
/// This separation means:
/// - We can swap Hive for SQLite without touching domain or presentation layers
/// - We can create a fake implementation for unit tests
/// - Business logic is completely isolated from data storage details
abstract class TransactionRepository {
  // ─── Transaction Operations ──────────────────────────────────

  /// Returns all transactions sorted by date (newest first).
  Future<List<Transaction>> getAllTransactions();

  /// Returns a single transaction by its ID.
  /// Returns null if not found.
  Future<Transaction?> getTransactionById(String id);

  /// Returns all transactions within a date range.
  /// Used for monthly/weekly reports.
  Future<List<Transaction>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Returns all transactions for a specific category.
  Future<List<Transaction>> getTransactionsByCategory(String categoryId);

  /// Returns all transactions of a specific type (income or expense).
  Future<List<Transaction>> getTransactionsByType(TransactionType type);

  /// Adds a new transaction to the database.
  /// Returns the saved transaction.
  Future<Transaction> addTransaction(Transaction transaction);

  /// Updates an existing transaction.
  /// Returns the updated transaction.
  Future<Transaction> updateTransaction(Transaction transaction);

  /// Deletes a transaction by its ID.
  Future<void> deleteTransaction(String id);

  /// Returns the total income for a given date range.
  Future<double> getTotalIncome({DateTime? startDate, DateTime? endDate});

  /// Returns the total expenses for a given date range.
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate});

  /// Returns the net balance (income - expenses) for a given date range.
  Future<double> getBalance({DateTime? startDate, DateTime? endDate});

  // ─── Category Operations ──────────────────────────────────────

  /// Returns all categories.
  Future<List<Category>> getAllCategories();

  /// Returns all categories of a specific type.
  Future<List<Category>> getCategoriesByType(TransactionType type);

  /// Adds a new category.
  Future<Category> addCategory(Category category);

  /// Updates an existing category.
  Future<Category> updateCategory(Category category);

  /// Deletes a category by its ID.
  /// Should not delete default categories.
  Future<void> deleteCategory(String id);
}
