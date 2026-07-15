import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/balance_card.dart';
import '../../domain/entities/transaction.dart';
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filters coming in a future update'),
                  duration: Duration(seconds: 2),
                ),
              );
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
                BalanceCard(summaryAsync: summaryAsync),
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
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Edit transaction coming in a future update'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}
