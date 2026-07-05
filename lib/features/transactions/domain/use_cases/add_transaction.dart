import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case to add a new transaction.
///
/// Validates the transaction before saving.
/// Throws [ArgumentError] if validation fails.
class AddTransaction {
  final TransactionRepository _repository;

  const AddTransaction(this._repository);

  /// Adds a new transaction after validation.
  ///
  /// Validation rules:
  /// - Title must not be empty
  /// - Amount must be greater than zero
  /// - Date must not be in the future
  Future<Transaction> call(Transaction transaction) async {
    // ─── Validation ─────────────────────────────────────────
    if (transaction.title.trim().isEmpty) {
      throw ArgumentError('Transaction title cannot be empty.');
    }

    if (transaction.amount <= 0) {
      throw ArgumentError('Transaction amount must be greater than zero.');
    }

    if (transaction.date.isAfter(DateTime.now())) {
      throw ArgumentError('Transaction date cannot be in the future.');
    }

    // ─── Save ───────────────────────────────────────────────
    return _repository.addTransaction(transaction);
  }
}
