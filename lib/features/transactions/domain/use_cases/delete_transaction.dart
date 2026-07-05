import 'package:koshly/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case to delete a transaction.
///
/// Validates that the ID is not empty before deleting.
/// Throws [ArgumentError] if validation fails.
class DeleteTransaction {
  final TransactionRepository _repository;

  const DeleteTransaction(this._repository);

  /// Deletes a transaction by its ID.
  ///
  /// Throws [ArgumentError] if ID is empty.
  Future<void> call(String id) async {
    // ─── Validation ─────────────────────────────────────────
    if (id.trim().isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty.');
    }

    // ─── Delete ─────────────────────────────────────────────
    return _repository.deleteTransaction(id);
  }
}
