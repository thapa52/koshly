import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_providers.dart';
import '../widgets/savings_goal_card.dart';

/// Main screen displaying all savings goals.
///
/// Shows:
/// - Savings summary card
/// - Active goals list
/// - Completed goals list
/// - FAB to add new goal
class SavingsListScreen extends ConsumerWidget {
  const SavingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(savingsNotifierProvider);
    final summaryAsync = ref.watch(savingsSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Savings Goals')),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48.0,
                    color: AppColors.expense,
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Something went wrong',
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    error.toString(),
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        data: (goals) {
          if (goals.isEmpty) {
            return _buildEmptyState(context);
          }

          final activeGoals = goals.where((g) => !g.isCompleted).toList();
          final completedGoals = goals.where((g) => g.isCompleted).toList();

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Summary Card ───────────────────────────
                _buildSummaryCard(context, summaryAsync),
                const SizedBox(height: 24.0),

                // ─── Active Goals ───────────────────────────
                if (activeGoals.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Active Goals'),
                  const SizedBox(height: 12.0),
                  ...activeGoals.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                      child: SavingsGoalCard(
                        goal: goal,
                        onAddContribution:
                            () => _showContributionDialog(context, ref, goal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],

                // ─── Completed Goals ────────────────────────
                if (completedGoals.isNotEmpty) ...[
                  _buildSectionTitle(context, 'Completed'),
                  const SizedBox(height: 12.0),
                  ...completedGoals.map(
                    (goal) => Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 12.0),
                      child: SavingsGoalCard(goal: goal),
                    ),
                  ),
                ],

                const SizedBox(height: 24.0),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.addSavingsGoal);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  /// Builds the overall savings summary card.
  Widget _buildSummaryCard(
    BuildContext context,
    AsyncValue<Map<String, double>> summaryAsync,
  ) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.savings, Color(0xFF2471A3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.savings.withValues(alpha: 0.3),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: summaryAsync.when(
        loading:
            () => const SizedBox(
              height: 100.0,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        error:
            (_, __) => const Text(
              'Unable to load summary',
              style: TextStyle(color: Colors.white),
            ),
        data: (summary) {
          final totalSaved = summary['totalSaved'] ?? 0.0;
          final totalTarget = summary['totalTarget'] ?? 0.0;
          final goalCount = (summary['goalCount'] ?? 0.0).toInt();
          final completedCount = (summary['completedCount'] ?? 0.0).toInt();

          return Column(
            children: [
              Text(
                'Total Saved',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                CurrencyFormatter.format(totalSaved),
                style: AppTextStyles.amountLarge.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4.0),
              Text(
                'of ${CurrencyFormatter.format(totalTarget)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSummaryChip('$goalCount Goals', Colors.white),
                  const SizedBox(width: 12.0),
                  _buildSummaryChip(
                    '$completedCount Completed',
                    AppColors.income,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  /// Builds a small chip for the summary card.
  Widget _buildSummaryChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// Builds a section title.
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: AppTextStyles.headlineMedium.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Builds the empty state.
  Widget _buildEmptyState(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 80.0,
            color: onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16.0),
          Text(
            'No savings goals yet',
            style: AppTextStyles.headlineMedium.copyWith(
              color: onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Tap the button below to create your first goal',
            style: AppTextStyles.bodyMedium.copyWith(
              color: onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the contribution dialog.
  void _showContributionDialog(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) {
    final controller = TextEditingController();
    final goalColor = Color(goal.colorValue);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Add to "${goal.title}"'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Remaining: ${CurrencyFormatter.format(goal.remainingAmount)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money, color: goalColor),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text.trim());
                if (amount == null || amount <= 0) return;

                Navigator.of(dialogContext).pop();

                await ref
                    .read(savingsNotifierProvider.notifier)
                    .addContribution(goalId: goal.id, amount: amount);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
