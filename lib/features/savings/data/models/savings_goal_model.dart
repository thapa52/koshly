import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/savings_goal.dart';

part 'savings_goal_model.g.dart';

/// Hive model for [SavingsGoal] entity.
///
/// This class is used exclusively by the data layer.
/// It is never exposed to the domain or presentation layers.
@HiveType(typeId: AppConstants.savingsGoalTypeId)
class SavingsGoalModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final double targetAmount;

  @HiveField(3)
  final double currentAmount;

  @HiveField(4)
  final int iconCode;

  @HiveField(5)
  final int colorValue;

  @HiveField(6)
  final DateTime? deadline;

  @HiveField(7)
  final String? note;

  @HiveField(8)
  final DateTime createdAt;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.iconCode,
    required this.colorValue,
    this.deadline,
    this.note,
    required this.createdAt,
  });

  /// Converts this Hive model to a domain entity.
  ///
  /// Called when reading FROM the database.
  SavingsGoal toEntity() {
    return SavingsGoal(
      id: id,
      title: title,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      iconCode: iconCode,
      colorValue: colorValue,
      deadline: deadline,
      note: note,
      createdAt: createdAt,
    );
  }

  /// Creates a Hive model from a domain entity.
  ///
  /// Called when writing TO the database.
  factory SavingsGoalModel.fromEntity(SavingsGoal entity) {
    return SavingsGoalModel(
      id: entity.id,
      title: entity.title,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
      deadline: entity.deadline,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }
}
