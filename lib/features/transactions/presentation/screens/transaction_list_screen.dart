import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/use_cases/get_transaction_summary.dart';
import '../providers/transaction_providers.dart';
import '../widgets/transaction_tile.dart';

/// Main screen displaying all transactions.
///
/// Shows:
/// - Balance summary card
/// - List of transactions
/// - FAB to add new transaction
class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionNotifierProvider);
    final summaryAsync = ref.watch(transactionSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: transactionsAsync.when(
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
        data:
            (transactions) => Column(
              children: [
                _buildSummaryCard(context, summaryAsync),
                Expanded(
                  child:
                      transactions.isEmpty
                          ? _buildEmptyState(context)
                          : _buildTransactionList(transactions),
                ),
              ],
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppRoutes.addTransaction);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }

  /// Builds the balance summary card at the top.
  Widget _buildSummaryCard(
    BuildContext context,
    AsyncValue<TransactionSummary> summaryAsync,
  ) {
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
            () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        error:
            (_, __) => const Text(
              'Unable to load summary',
              style: TextStyle(color: Colors.white),
            ),
        data:
            (summary) => Column(
              children: [
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

  /// Builds the empty state when no transactions exist.
  Widget _buildEmptyState(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80.0,
            color: onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16.0),
          Text(
            'No transactions yet',
            style: AppTextStyles.headlineMedium.copyWith(
              color: onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Tap the + button to add your first transaction',
            style: AppTextStyles.bodyMedium.copyWith(
              color: onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the transaction list.
  Widget _buildTransactionList(List<Transaction> transactions) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: transactions.length,
      separatorBuilder:
          (context, index) => Divider(
            height: 1.0,
            indent: 78.0,
            color: Theme.of(context).dividerColor,
          ),
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionTile(
          transaction: transaction,
          onTap: () {
            // TODO: Navigate to edit transaction screen
          },
        );
      },
    );
  }
}
