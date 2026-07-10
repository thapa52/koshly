import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/savings_goal.dart';

/// A card widget displaying a savings goal with progress.
///
/// Shows:
/// - Goal icon and title
/// - Progress bar
/// - Current vs target amount
/// - Completion percentage
/// - Optional deadline
/// - Completed badge when goal is reached
///
/// Usage:
/// ```dart
/// SavingsGoalCard(
///   goal: myGoal,
///   onTap: () => navigateToDetail(myGoal),
///   onAddContribution: () => showContributionDialog(myGoal),
/// )
/// ```
class SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback? onTap;
  final VoidCallback? onAddContribution;

  const SavingsGoalCard({
    super.key,
    required this.goal,
    this.onTap,
    this.onAddContribution,
  });

  @override
  Widget build(BuildContext context) {
    final goalColor = Color(goal.colorValue);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color:
                goal.isCompleted
                    ? AppColors.success.withValues(alpha: 0.5)
                    : Theme.of(context).dividerColor,
            width: goal.isCompleted ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header Row ───────────────────────────────────
            _buildHeader(context, goalColor, onSurface),
            const SizedBox(height: 16.0),

            // ─── Progress Bar ──────────────────────────────────
            _buildProgressBar(goalColor),
            const SizedBox(height: 10.0),

            // ─── Amount Row ────────────────────────────────────
            _buildAmountRow(onSurface),
            const SizedBox(height: 12.0),

            // ─── Footer Row ────────────────────────────────────
            _buildFooterRow(context, goalColor, onSurface),
          ],
        ),
      ),
    );
  }

  /// Builds the header with icon, title, and completed badge.
  Widget _buildHeader(BuildContext context, Color goalColor, Color onSurface) {
    return Row(
      children: [
        // Goal icon
        Container(
          width: 44.0,
          height: 44.0,
          decoration: BoxDecoration(
            color: goalColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Icon(
            IconData(goal.iconCode, fontFamily: 'MaterialIcons'),
            color: goalColor,
            size: 22.0,
          ),
        ),
        const SizedBox(width: 12.0),

        // Title and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                goal.title,
                style: AppTextStyles.headlineSmall.copyWith(color: onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (goal.isOverdue)
                Text(
                  'Overdue',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.expense,
                  ),
                ),
            ],
          ),
        ),

        // Completed badge or percentage
        if (goal.isCompleted)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              'Completed',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            '${goal.progressPercentage.toStringAsFixed(0)}%',
            style: AppTextStyles.headlineMedium.copyWith(
              color: goalColor,
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }

  /// Builds the animated progress bar.
  Widget _buildProgressBar(Color goalColor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: LinearProgressIndicator(
        value: goal.progressFraction,
        backgroundColor: goalColor.withValues(alpha: 0.12),
        valueColor: AlwaysStoppedAnimation<Color>(
          goal.isCompleted ? AppColors.success : goalColor,
        ),
        minHeight: 8.0,
      ),
    );
  }

  /// Builds the current vs target amount row.
  Widget _buildAmountRow(Color onSurface) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          CurrencyFormatter.format(goal.currentAmount),
          style: AppTextStyles.amountSmall.copyWith(color: onSurface),
        ),
        Text(
          'of ${CurrencyFormatter.format(goal.targetAmount)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  /// Builds the footer with deadline and add contribution button.
  Widget _buildFooterRow(
    BuildContext context,
    Color goalColor,
    Color onSurface,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Deadline or remaining amount
        if (goal.hasDeadline)
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 12.0,
                color:
                    goal.isOverdue
                        ? AppColors.expense
                        : onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 4.0),
              Text(
                DateFormatter.formatDate(goal.deadline!),
                style: AppTextStyles.labelSmall.copyWith(
                  color:
                      goal.isOverdue
                          ? AppColors.expense
                          : onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          )
        else
          Text(
            '${CurrencyFormatter.format(goal.remainingAmount)} remaining',
            style: AppTextStyles.labelSmall.copyWith(
              color: onSurface.withValues(alpha: 0.5),
            ),
          ),

        // Add contribution button
        if (!goal.isCompleted && onAddContribution != null)
          GestureDetector(
            onTap: onAddContribution,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 6.0,
              ),
              decoration: BoxDecoration(
                color: goalColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 14.0, color: goalColor),
                  const SizedBox(width: 4.0),
                  Text(
                    'Add',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: goalColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
