import '../entities/savings_goal.dart';
import '../repositories/savings_repository.dart';

/// Use case to update an existing savings goal.
///
/// Validates the updated data before saving.
/// Throws [ArgumentError] if validation fails.
class UpdateSavingsGoal {
  final SavingsRepository _repository;

  const UpdateSavingsGoal(this._repository);

  /// Updates a savings goal after validation.
  ///
  /// Same validation rules as [AddSavingsGoal]:
  /// - Title must not be empty
  /// - Target amount must be greater than zero
  /// - Current amount must not be negative
  /// - Current amount must not exceed target amount
  /// - Deadline (if provided) must be in the future
  Future<SavingsGoal> call(SavingsGoal goal) async {
    // ─── Validation ─────────────────────────────────────────
    if (goal.title.trim().isEmpty) {
      throw ArgumentError('Goal title cannot be empty.');
    }

    if (goal.targetAmount <= 0) {
      throw ArgumentError('Target amount must be greater than zero.');
    }

    if (goal.currentAmount < 0) {
      throw ArgumentError('Current amount cannot be negative.');
    }

    if (goal.currentAmount > goal.targetAmount) {
      throw ArgumentError('Current amount cannot exceed target amount.');
    }

    if (goal.deadline != null && goal.deadline!.isBefore(DateTime.now())) {
      throw ArgumentError('Deadline must be in the future.');
    }

    // ─── Update ─────────────────────────────────────────────
    return _repository.updateGoal(goal);
  }
}
