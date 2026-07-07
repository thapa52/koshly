/// Represents the current status of a savings goal.
enum SavingsGoalStatus {
  inProgress('In Progress'),
  completed('Completed');

  /// Human-readable label for UI display.
  final String label;

  const SavingsGoalStatus(this.label);

  /// Whether the goal is still being saved toward.
  bool get isInProgress => this == SavingsGoalStatus.inProgress;

  /// Whether the goal has been fully completed.
  bool get isCompleted => this == SavingsGoalStatus.completed;
}
