import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/savings_goal.dart';
import '../../domain/use_cases/add_contribution.dart';
import '../../domain/use_cases/add_savings_goal.dart';
import '../../domain/use_cases/delete_savings_goal.dart';
import '../../domain/use_cases/get_savings_goals.dart';
import '../../domain/use_cases/update_savings_goal.dart';
import 'savings_repository_provider.dart';

/// Manages the state of all savings goals.
///
/// Automatically loads goals from Hive on first access.
/// All CRUD operations go through domain use cases.
///
/// Usage in widgets:
/// ```dart
/// final goalsAsync = ref.watch(savingsNotifierProvider);
/// goalsAsync.when(
///   data: (goals) => ListView(...),
///   loading: () => CircularProgressIndicator(),
///   error: (e, st) => Text('Error: $e'),
/// );
/// ```
class SavingsNotifier extends AsyncNotifier<List<SavingsGoal>> {
  late final GetSavingsGoals _getSavingsGoals;
  late final AddSavingsGoal _addSavingsGoal;
  late final UpdateSavingsGoal _updateSavingsGoal;
  late final DeleteSavingsGoal _deleteSavingsGoal;
  late final AddContribution _addContribution;

  @override
  FutureOr<List<SavingsGoal>> build() async {
    final repository = ref.read(savingsRepositoryProvider);

    _getSavingsGoals = GetSavingsGoals(repository);
    _addSavingsGoal = AddSavingsGoal(repository);
    _updateSavingsGoal = UpdateSavingsGoal(repository);
    _deleteSavingsGoal = DeleteSavingsGoal(repository);
    _addContribution = AddContribution(repository);

    return _getSavingsGoals.all();
  }

  /// Adds a new savings goal.
  Future<void> addGoal(SavingsGoal goal) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _addSavingsGoal.call(goal);
      return _getSavingsGoals.all();
    });
  }

  /// Updates an existing savings goal.
  Future<void> updateGoal(SavingsGoal goal) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _updateSavingsGoal.call(goal);
      return _getSavingsGoals.all();
    });
  }

  /// Deletes a savings goal by ID.
  Future<void> deleteGoal(String id) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _deleteSavingsGoal.call(id);
      return _getSavingsGoals.all();
    });
  }

  /// Adds a contribution to a savings goal.
  Future<void> addContribution({
    required String goalId,
    required double amount,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _addContribution.call(goalId: goalId, amount: amount);
      return _getSavingsGoals.all();
    });
  }
}

/// Provider for [SavingsNotifier].
final savingsNotifierProvider =
    AsyncNotifierProvider<SavingsNotifier, List<SavingsGoal>>(
      SavingsNotifier.new,
    );

// ─── Derived Providers ──────────────────────────────────────────

/// Provides only active (in progress) savings goals.
final activeGoalsProvider = Provider<AsyncValue<List<SavingsGoal>>>((ref) {
  final goalsAsync = ref.watch(savingsNotifierProvider);

  return goalsAsync.whenData(
    (goals) => goals.where((g) => !g.isCompleted).toList(),
  );
});

/// Provides only completed savings goals.
final completedGoalsProvider = Provider<AsyncValue<List<SavingsGoal>>>((ref) {
  final goalsAsync = ref.watch(savingsNotifierProvider);

  return goalsAsync.whenData(
    (goals) => goals.where((g) => g.isCompleted).toList(),
  );
});

/// Provides overall savings summary.
///
/// Returns a map with:
/// - totalSaved: sum of all currentAmounts
/// - totalTarget: sum of all targetAmounts
/// - goalCount: total number of goals
/// - completedCount: number of completed goals
final savingsSummaryProvider = Provider<AsyncValue<Map<String, double>>>((ref) {
  final goalsAsync = ref.watch(savingsNotifierProvider);

  return goalsAsync.whenData((goals) {
    final totalSaved = goals.fold<double>(
      0.0,
      (sum, g) => sum + g.currentAmount,
    );
    final totalTarget = goals.fold<double>(
      0.0,
      (sum, g) => sum + g.targetAmount,
    );
    final completedCount = goals.where((g) => g.isCompleted).length.toDouble();

    return {
      'totalSaved': totalSaved,
      'totalTarget': totalTarget,
      'goalCount': goals.length.toDouble(),
      'completedCount': completedCount,
    };
  });
});
