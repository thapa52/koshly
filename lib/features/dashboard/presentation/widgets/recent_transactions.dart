import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';

/// Displays the 5 most recent transactions on the dashboard.
///
/// Reuses [TransactionTile] for consistent UI.
/// Has a "See All" button that navigates to the transactions tab.
///
/// Usage:
/// ```dart
/// const RecentTransactions()
/// ```
class RecentTransactions extends ConsumerWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentTransactionsProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        // ─── Header Row ───────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: AppTextStyles.headlineMedium.copyWith(color: onSurface),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.transactions),
                child: const Text('See All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),

        // ─── Transaction List ─────────────────────────────────
        recentAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, st) => Center(
                child: Text(
                  'Unable to load transactions',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Text(
                    'No transactions yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Column(
                  children:
                      transactions.asMap().entries.map((entry) {
                        final index = entry.key;
                        final transaction = entry.value;
                        final isLast = index == transactions.length - 1;

                        return Column(
                          children: [
                            TransactionTile(
                              transaction: transaction,
                              onTap: () => context.go(AppRoutes.transactions),
                            ),
                            if (!isLast)
                              Divider(
                                height: 1.0,
                                indent: 78.0,
                                color: Theme.of(context).dividerColor,
                              ),
                          ],
                        );
                      }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
