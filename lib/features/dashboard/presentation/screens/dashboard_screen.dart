import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/balance_card.dart';
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
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'Reports',
            onPressed: () => context.push(AppRoutes.reports),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notification Settings',
            onPressed: () => context.go(AppRoutes.settings),
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
            BalanceCard(summaryAsync: summaryAsync),
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
}
