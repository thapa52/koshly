import '../entities/savings_goal.dart';
import '../repositories/savings_repository.dart';

/// Use case to retrieve savings goals from the repository.
///
/// Supports multiple query methods:
/// - Get all goals
/// - Get active (in progress) goals
/// - Get completed goals
class GetSavingsGoals {
  final SavingsRepository _repository;

  const GetSavingsGoals(this._repository);

  /// Returns all savings goals sorted by creation date (newest first).
  Future<List<SavingsGoal>> all() async {
    return _repository.getAllGoals();
  }

  /// Returns only goals that are still in progress.
  Future<List<SavingsGoal>> active() async {
    return _repository.getActiveGoals();
  }

  /// Returns only goals that have been completed.
  Future<List<SavingsGoal>> completed() async {
    return _repository.getCompletedGoals();
  }

  /// Returns a single goal by ID.
  /// Returns null if not found.
  Future<SavingsGoal?> byId(String id) async {
    return _repository.getGoalById(id);
  }
}
