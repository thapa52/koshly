import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/transactions/domain/use_cases/get_transaction_summary.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';

/// A reusable balance card widget displaying financial summary.
///
/// Shows:
/// - Total balance with gradient background
/// - Income summary
/// - Expense summary
///
/// Used on both the Dashboard and Transaction List screens.
///
/// Usage:
/// ```dart
/// BalanceCard(
///   summaryAsync: ref.watch(transactionSummaryProvider),
/// )
/// ```
class BalanceCard extends StatelessWidget {
  final AsyncValue<TransactionSummary> summaryAsync;

  const BalanceCard({super.key, required this.summaryAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
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
