import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/use_cases/get_transaction_summary.dart';
import '../../../transactions/presentation/widgets/transaction_tile.dart';
import '../../domain/services/export_service.dart';
import '../providers/report_providers.dart';

/// Reports screen with monthly summary and export options.
///
/// Shows:
/// - Month navigator
/// - Financial summary card
/// - Transaction list for selected month
/// - Export buttons (CSV, PDF)
class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = ref.watch(reportPeriodProvider);
    final transactionsAsync = ref.watch(reportTransactionsProvider);
    final summaryAsync = ref.watch(reportSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Go to current month',
            onPressed: () {
              ref.read(reportPeriodProvider.notifier).goToCurrentMonth();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── Month Navigator ──────────────────────────────
          _buildMonthNavigator(context, ref, period),

          // ─── Content ──────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16.0),

                  // ─── Summary Card ─────────────────────────
                  _buildSummaryCard(context, summaryAsync),
                  const SizedBox(height: 24.0),

                  // ─── Export Buttons ────────────────────────
                  _buildExportButtons(
                    context,
                    ref,
                    transactionsAsync,
                    summaryAsync,
                    period,
                  ),
                  const SizedBox(height: 24.0),

                  // ─── Transaction List ─────────────────────
                  _buildTransactionList(context, transactionsAsync),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the month navigation bar.
  Widget _buildMonthNavigator(
    BuildContext context,
    WidgetRef ref,
    ReportPeriod period,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref.read(reportPeriodProvider.notifier).goToPreviousMonth();
            },
          ),
          Column(
            children: [
              Text(
                period.label,
                style: AppTextStyles.headlineMedium.copyWith(color: onSurface),
              ),
              if (period.isCurrentMonth)
                Text(
                  'Current Month',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                period.isCurrentMonth
                    ? null
                    : () {
                      ref.read(reportPeriodProvider.notifier).goToNextMonth();
                    },
          ),
        ],
      ),
    );
  }

  /// Builds the monthly summary card.
  Widget _buildSummaryCard(
    BuildContext context,
    AsyncValue<TransactionSummary> summaryAsync,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: summaryAsync.when(
        loading:
            () => const SizedBox(
              height: 100.0,
              child: Center(child: CircularProgressIndicator()),
            ),
        error: (_, __) => const Text('Unable to load summary'),
        data:
            (summary) => Column(
              children: [
                // ─── Income Row ──────────────────────────────
                _buildSummaryRow(
                  context: context,
                  icon: Icons.arrow_downward,
                  label: 'Income',
                  amount: summary.totalIncome,
                  color: AppColors.income,
                ),
                const SizedBox(height: 14.0),

                // ─── Expense Row ─────────────────────────────
                _buildSummaryRow(
                  context: context,
                  icon: Icons.arrow_upward,
                  label: 'Expenses',
                  amount: summary.totalExpenses,
                  color: AppColors.expense,
                ),

                Divider(height: 28.0, color: Theme.of(context).dividerColor),

                // ─── Balance Row ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Net Balance',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: onSurface,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(summary.balance),
                      style: AppTextStyles.amountMedium.copyWith(
                        color:
                            summary.isPositiveBalance
                                ? AppColors.income
                                : AppColors.expense,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8.0),

                // ─── Transaction Count ───────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${summary.transactionCount} transactions',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      ),
    );
  }

  /// Builds a single summary row (income or expense).
  Widget _buildSummaryRow({
    required BuildContext context,
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
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(icon, color: color, size: 18.0),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          CurrencyFormatter.format(amount),
          style: AppTextStyles.amountSmall.copyWith(color: color),
        ),
      ],
    );
  }

  /// Builds the export buttons row.
  Widget _buildExportButtons(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Transaction>> transactionsAsync,
    AsyncValue<TransactionSummary> summaryAsync,
    ReportPeriod period,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.table_chart_outlined, size: 18.0),
              label: const Text('Export CSV'),
              onPressed:
                  () => _handleExport(
                    context: context,
                    ref: ref,
                    transactionsAsync: transactionsAsync,
                    summaryAsync: summaryAsync,
                    period: period,
                    exportProvider: csvExportServiceProvider,
                  ),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.picture_as_pdf, size: 18.0),
              label: const Text('Export PDF'),
              onPressed:
                  () => _handleExport(
                    context: context,
                    ref: ref,
                    transactionsAsync: transactionsAsync,
                    summaryAsync: summaryAsync,
                    period: period,
                    exportProvider: pdfExportServiceProvider,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the export and share flow.
  Future<void> _handleExport({
    required BuildContext context,
    required WidgetRef ref,
    required AsyncValue<List<Transaction>> transactionsAsync,
    required AsyncValue<TransactionSummary> summaryAsync,
    required ReportPeriod period,
    required Provider<ExportService> exportProvider,
  }) async {
    final transactions = transactionsAsync.valueOrNull;
    final summary = summaryAsync.valueOrNull;

    if (transactions == null || transactions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No transactions to export for this period'),
          ),
        );
      }
      return;
    }

    if (summary == null) return;

    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Generating report...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      final exportService = ref.read(exportProvider);
      final result = await exportService.exportTransactions(
        transactions: transactions,
        title: '${period.label} Report',
        totalIncome: summary.totalIncome,
        totalExpenses: summary.totalExpenses,
      );

      // Share the file
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(result.file.path)],
          subject: 'Koshly - ${period.label} Report',
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  /// Builds the transaction list for the selected month.
  Widget _buildTransactionList(
    BuildContext context,
    AsyncValue<List<Transaction>> transactionsAsync,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Transactions',
            style: AppTextStyles.headlineMedium.copyWith(color: onSurface),
          ),
        ),
        const SizedBox(height: 8.0),
        transactionsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (e, st) => Center(child: Text('Unable to load transactions: $e')),
          data: (transactions) {
            if (transactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 48.0,
                        color: onSurface.withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 12.0),
                      Text(
                        'No transactions this month',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
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
                            TransactionTile(transaction: transaction),
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
