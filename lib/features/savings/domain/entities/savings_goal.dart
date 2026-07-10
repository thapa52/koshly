import 'savings_goal_status.dart';

/// Represents a savings goal.
///
/// A savings goal has:
/// - A target amount the user wants to save
/// - A current amount already saved
/// - An optional deadline
/// - A status (in progress or completed)
///
/// Example:
/// ```dart
/// final goal = SavingsGoal(
///   id: 'goal-1',
///   title: 'Emergency Fund',
///   targetAmount: 10000.0,
///   currentAmount: 3500.0,
///   iconCode: Icons.shield.codePoint,
///   colorValue: AppColors.savings.toARGB32(),
///   createdAt: DateTime.now(),
/// );
///
/// goal.progressPercentage; // 35.0
/// goal.remainingAmount;    // 6500.0
/// goal.isCompleted;        // false
/// ```
class SavingsGoal {
  /// Unique identifier for the goal
  final String id;

  /// Name of the goal (e.g., "Emergency Fund", "Vacation")
  final String title;

  /// The amount the user wants to save
  final double targetAmount;

  /// The amount already saved toward this goal
  final double currentAmount;

  /// Icon code point from Material Icons
  final int iconCode;

  /// Color value for the goal
  final int colorValue;

  /// Optional deadline for the goal
  final DateTime? deadline;

  /// Optional note for additional details
  final String? note;

  /// When this goal was created
  final DateTime createdAt;

  const SavingsGoal({
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

  // ─── Computed Properties ─────────────────────────────────────

  /// Progress percentage from 0.0 to 100.0.
  ///
  /// Capped at 100.0 even if currentAmount exceeds targetAmount.
  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    final percentage = (currentAmount / targetAmount) * 100;
    return percentage > 100.0 ? 100.0 : percentage;
  }

  /// Progress as a fraction from 0.0 to 1.0.
  ///
  /// Used directly by Flutter progress indicators.
  double get progressFraction {
    if (targetAmount <= 0) return 0.0;
    final fraction = currentAmount / targetAmount;
    return fraction > 1.0 ? 1.0 : fraction;
  }

  /// Remaining amount to reach the target.
  ///
  /// Returns 0.0 if goal is already completed.
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining < 0 ? 0.0 : remaining;
  }

  /// Whether the goal has been completed.
  bool get isCompleted => currentAmount >= targetAmount;

  /// Current status based on progress.
  SavingsGoalStatus get status =>
      isCompleted ? SavingsGoalStatus.completed : SavingsGoalStatus.inProgress;

  /// Whether the goal has a deadline.
  bool get hasDeadline => deadline != null;

  /// Whether the deadline has passed.
  bool get isOverdue {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  /// Number of days remaining until the deadline.
  /// Returns null if no deadline is set.
  /// Returns 0 if deadline has passed.
  int? get daysRemaining {
    if (deadline == null) return null;
    final remaining = deadline!.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  // ─── Copy With ───────────────────────────────────────────────

  /// Creates a copy of this goal with updated fields.
  SavingsGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    int? iconCode,
    int? colorValue,
    DateTime? deadline,
    String? note,
    DateTime? createdAt,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      deadline: deadline ?? this.deadline,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ─── Equality ────────────────────────────────────────────────

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SavingsGoal && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SavingsGoal(id: $id, title: $title, progress: ${progressPercentage.toStringAsFixed(1)}%)';
}
