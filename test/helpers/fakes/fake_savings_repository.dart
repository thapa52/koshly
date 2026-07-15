import 'package:koshly/features/savings/domain/entities/savings_goal.dart';
import 'package:koshly/features/savings/domain/repositories/savings_repository.dart';

/// A fake implementation of [SavingsRepository] for testing.
///
/// Stores data in memory using simple lists.
/// Behaves like a real repository without Hive dependency.
class FakeSavingsRepository implements SavingsRepository {
  /// In-memory storage for savings goals
  final List<SavingsGoal> _goals = [];

  /// Provides read access to stored goals for test assertions.
  List<SavingsGoal> get goals => List.unmodifiable(_goals);

  /// Seeds test goals for convenience.
  void seedGoals(List<SavingsGoal> goals) {
    _goals.addAll(goals);
  }

  /// Clears all stored data.
  void reset() {
    _goals.clear();
  }

  // ─── CRUD Operations ─────────────────────────────────────────

  @override
  Future<List<SavingsGoal>> getAllGoals() async {
    final sorted = List<SavingsGoal>.from(_goals);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<SavingsGoal?> getGoalById(String id) async {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<SavingsGoal> addGoal(SavingsGoal goal) async {
    _goals.add(goal);
    return goal;
  }

  @override
  Future<SavingsGoal> updateGoal(SavingsGoal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
    }
    return goal;
  }

  @override
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
  }

  // ─── Progress Operations ──────────────────────────────────────

  @override
  Future<SavingsGoal> addContribution(String goalId, double amount) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index == -1) {
      throw ArgumentError('Savings goal with ID $goalId not found.');
    }

    final updatedGoal = _goals[index].copyWith(
      currentAmount: _goals[index].currentAmount + amount,
    );
    _goals[index] = updatedGoal;
    return updatedGoal;
  }

  // ─── Query Operations ─────────────────────────────────────────

  @override
  Future<List<SavingsGoal>> getActiveGoals() async {
    return _goals.where((g) => !g.isCompleted).toList();
  }

  @override
  Future<List<SavingsGoal>> getCompletedGoals() async {
    return _goals.where((g) => g.isCompleted).toList();
  }

  @override
  Future<double> getTotalSaved() async {
    return _goals.fold<double>(0.0, (sum, g) => sum + g.currentAmount);
  }

  @override
  Future<double> getTotalTarget() async {
    return _goals.fold<double>(0.0, (sum, g) => sum + g.targetAmount);
  }
}
