import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';
import '../models/savings_goal_model.dart';

/// Hive implementation of [SavingsRepository].
///
/// This class is the only place where Hive code exists
/// for the savings feature.
class HiveSavingsRepository implements SavingsRepository {
  /// Hive box for storing savings goals
  late Box<SavingsGoalModel> _savingsBox;

  /// Whether the repository has been initialized
  bool _isInitialized = false;

  /// Initializes the repository by opening the Hive box.
  /// Must be called before any other method.
  Future<void> init() async {
    if (_isInitialized) return;

    if (!Hive.isAdapterRegistered(AppConstants.savingsGoalTypeId)) {
      Hive.registerAdapter(SavingsGoalModelAdapter());
    }

    _savingsBox = await Hive.openBox<SavingsGoalModel>(AppConstants.savingsBox);

    _isInitialized = true;
  }

  /// Ensures the repository is initialized before use.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'HiveSavingsRepository is not initialized. Call init() first.',
      );
    }
  }

  // ─── CRUD Operations ─────────────────────────────────────────

  @override
  Future<List<SavingsGoal>> getAllGoals() async {
    _ensureInitialized();

    final models = _savingsBox.values.toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<SavingsGoal?> getGoalById(String id) async {
    _ensureInitialized();

    final model = _savingsBox.get(id);
    return model?.toEntity();
  }

  @override
  Future<SavingsGoal> addGoal(SavingsGoal goal) async {
    _ensureInitialized();

    final model = SavingsGoalModel.fromEntity(goal);
    await _savingsBox.put(goal.id, model);

    return goal;
  }

  @override
  Future<SavingsGoal> updateGoal(SavingsGoal goal) async {
    _ensureInitialized();

    final model = SavingsGoalModel.fromEntity(goal);
    await _savingsBox.put(goal.id, model);

    return goal;
  }

  @override
  Future<void> deleteGoal(String id) async {
    _ensureInitialized();

    await _savingsBox.delete(id);
  }

  // ─── Progress Operations ──────────────────────────────────────

  @override
  Future<SavingsGoal> addContribution(String goalId, double amount) async {
    _ensureInitialized();

    final model = _savingsBox.get(goalId);
    if (model == null) {
      throw ArgumentError('Savings goal with ID $goalId not found.');
    }

    final updatedModel = SavingsGoalModel(
      id: model.id,
      title: model.title,
      targetAmount: model.targetAmount,
      currentAmount: model.currentAmount + amount,
      iconCode: model.iconCode,
      colorValue: model.colorValue,
      deadline: model.deadline,
      note: model.note,
      createdAt: model.createdAt,
    );

    await _savingsBox.put(goalId, updatedModel);
    return updatedModel.toEntity();
  }

  // ─── Query Operations ─────────────────────────────────────────

  @override
  Future<List<SavingsGoal>> getActiveGoals() async {
    _ensureInitialized();

    final models =
        _savingsBox.values
            .where((model) => model.currentAmount < model.targetAmount)
            .toList();

    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<SavingsGoal>> getCompletedGoals() async {
    _ensureInitialized();

    final models =
        _savingsBox.values
            .where((model) => model.currentAmount >= model.targetAmount)
            .toList();

    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<double> getTotalSaved() async {
    _ensureInitialized();

    return _savingsBox.values.fold<double>(
      0.0,
      (sum, model) => sum + model.currentAmount,
    );
  }

  @override
  Future<double> getTotalTarget() async {
    _ensureInitialized();

    return _savingsBox.values.fold<double>(
      0.0,
      (sum, model) => sum + model.targetAmount,
    );
  }
}
