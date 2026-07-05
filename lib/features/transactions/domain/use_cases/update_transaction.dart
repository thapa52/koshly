import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case to update an existing transaction.
///
/// Validates the updated data before saving.
/// Throws [ArgumentError] if validation fails.
class UpdateTransaction {
  final TransactionRepository _repository;

  const UpdateTransaction(this._repository);

  /// Updates a transaction after validation.
  ///
  /// Same validation rules as [AddTransaction]:
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

    // ─── Update ─────────────────────────────────────────────
    return _repository.updateTransaction(transaction);
  }
}
