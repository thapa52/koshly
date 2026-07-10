import '../entities/savings_goal.dart';
import '../repositories/savings_repository.dart';

/// Use case to add a contribution to a savings goal.
///
/// A contribution is an amount of money added toward
/// a savings goal's current amount.
///
/// Example:
/// ```dart
/// // User saves $200 toward their vacation goal
/// await addContribution.call(
///   goalId: 'goal-vacation',
///   amount: 200.0,
/// );
/// ```
class AddContribution {
  final SavingsRepository _repository;

  const AddContribution(this._repository);

  /// Adds a contribution amount to a savings goal.
  ///
  /// Validation rules:
  /// - Goal ID must not be empty
  /// - Amount must be greater than zero
  ///
  /// Returns the updated [SavingsGoal] after the contribution.
  Future<SavingsGoal> call({
    required String goalId,
    required double amount,
  }) async {
    // ─── Validation ─────────────────────────────────────────
    if (goalId.trim().isEmpty) {
      throw ArgumentError('Goal ID cannot be empty.');
    }

    if (amount <= 0) {
      throw ArgumentError('Contribution amount must be greater than zero.');
    }

    // ─── Add Contribution ───────────────────────────────────
    return _repository.addContribution(goalId, amount);
  }
}
