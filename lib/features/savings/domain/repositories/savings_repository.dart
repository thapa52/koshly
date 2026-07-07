import '../entities/savings_goal.dart';

/// Abstract interface for savings goal data operations.
///
/// The domain layer depends on this interface.
/// The data layer implements this interface.
///
/// This separation means:
/// - We can swap Hive for any other database without
///   touching domain or presentation layers
/// - We can create a fake implementation for unit tests
abstract class SavingsRepository {
  // ─── CRUD Operations ─────────────────────────────────────────

  /// Returns all savings goals sorted by creation date (newest first).
  Future<List<SavingsGoal>> getAllGoals();

  /// Returns a single savings goal by its ID.
  /// Returns null if not found.
  Future<SavingsGoal?> getGoalById(String id);

  /// Adds a new savings goal.
  /// Returns the saved goal.
  Future<SavingsGoal> addGoal(SavingsGoal goal);

  /// Updates an existing savings goal.
  /// Returns the updated goal.
  Future<SavingsGoal> updateGoal(SavingsGoal goal);

  /// Deletes a savings goal by its ID.
  Future<void> deleteGoal(String id);

  // ─── Progress Operations ──────────────────────────────────────

  /// Adds an amount to the current savings of a goal.
  ///
  /// Example:
  /// ```dart
  /// // Goal currently has $500, adding $200
  /// await repository.addContribution('goal-1', 200.0);
  /// // Goal now has $700
  /// ```
  Future<SavingsGoal> addContribution(String goalId, double amount);

  // ─── Query Operations ─────────────────────────────────────────

  /// Returns all goals that are still in progress.
  Future<List<SavingsGoal>> getActiveGoals();

  /// Returns all goals that have been completed.
  Future<List<SavingsGoal>> getCompletedGoals();

  /// Returns the total amount saved across all goals.
  Future<double> getTotalSaved();

  /// Returns the total target amount across all goals.
  Future<double> getTotalTarget();
}
