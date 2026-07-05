import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/domain/use_cases/get_transaction_summary.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../widgets/greeting_header.dart';
import '../widgets/recent_transactions.dart';
import '../widgets/spending_pie_chart.dart';
import '../widgets/weekly_bar_chart.dart';

/// Main dashboard screen showing financial overview.
///
/// Assembles:
/// - Greeting header
/// - Balance summary card
/// - Spending pie chart
/// - Weekly bar chart
/// - Recent transactions
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(transactionSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koshly'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Greeting ───────────────────────────────────
            const GreetingHeader(),
            const SizedBox(height: 12.0),

            // ─── Balance Card ───────────────────────────────
            _buildBalanceCard(context, summaryAsync),
            const SizedBox(height: 24.0),

            // ─── Spending Pie Chart ─────────────────────────
            const SpendingPieChart(),
            const SizedBox(height: 24.0),

            // ─── Weekly Bar Chart ───────────────────────────
            const WeeklyBarChart(),
            const SizedBox(height: 24.0),

            // ─── Recent Transactions ────────────────────────
            const RecentTransactions(),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addTransaction),
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the balance summary card.
  Widget _buildBalanceCard(
    BuildContext context,
    AsyncValue<TransactionSummary> summaryAsync,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12.0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: summaryAsync.when(
        loading:
            () => const SizedBox(
              height: 120.0,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        error:
            (_, __) => const SizedBox(
              height: 120.0,
              child: Center(
                child: Text(
                  'Unable to load summary',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        data:
            (summary) => Column(
              children: [
                // ─── Total Balance ──────────────────────────────
                Text(
                  'Total Balance',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  CurrencyFormatter.format(summary.balance),
                  style: AppTextStyles.amountLarge.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20.0),

                // ─── Income & Expense Row ───────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem(
                      icon: Icons.arrow_downward,
                      label: 'Income',
                      amount: summary.totalIncome,
                      color: AppColors.income,
                    ),
                    Container(
                      height: 40.0,
                      width: 1.0,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    _buildSummaryItem(
                      icon: Icons.arrow_upward,
                      label: 'Expense',
                      amount: summary.totalExpenses,
                      color: AppColors.expense,
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }

  /// Builds a single income/expense summary item.
  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(icon, color: color, size: 18.0),
        ),
        const SizedBox(width: 10.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 2.0),
            Text(
              CurrencyFormatter.format(amount),
              style: AppTextStyles.amountSmall.copyWith(color: Colors.white),
            ),
          ],
        ),
      ],
    );
  }
}
