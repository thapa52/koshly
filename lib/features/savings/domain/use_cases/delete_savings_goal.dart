import '../repositories/savings_repository.dart';

/// Use case to delete a savings goal.
///
/// Validates that the ID is not empty before deleting.
/// Throws [ArgumentError] if validation fails.
class DeleteSavingsGoal {
  final SavingsRepository _repository;

  const DeleteSavingsGoal(this._repository);

  /// Deletes a savings goal by its ID.
  ///
  /// Throws [ArgumentError] if ID is empty.
  Future<void> call(String id) async {
    // ─── Validation ─────────────────────────────────────────
    if (id.trim().isEmpty) {
      throw ArgumentError('Goal ID cannot be empty.');
    }

    // ─── Delete ─────────────────────────────────────────────
    return _repository.deleteGoal(id);
  }
}
