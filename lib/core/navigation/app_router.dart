import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/savings/presentation/screens/add_savings_goal_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/transactions/presentation/screens/add_transaction_screen.dart';
import '../../features/transactions/presentation/screens/transaction_list_screen.dart';
import 'scaffold_with_nav_bar.dart';

/// All route paths used in the app.
///
/// Never hardcode route strings in screens.
/// Always reference from here.
class AppRoutes {
  AppRoutes._();

  // ─── Tab Routes ──────────────────────────────────────────
  static const String dashboard = '/dashboard';
  static const String transactions = '/transactions';
  static const String savings = '/savings';
  static const String settings = '/settings';
  static const String addSavingsGoal = '/savings/add';

  // ─── Sub Routes ──────────────────────────────────────────
  static const String addTransaction = '/transactions/add';
}

/// Creates and configures the GoRouter instance.
///
/// Uses ShellRoute for bottom navigation bar support.
/// Each tab maintains its own navigation stack.
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.dashboard,
  routes: [
    // ─── Shell Route (Bottom Navigation Bar) ──────────────
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        // ─── Dashboard Tab ────────────────────────────────
        GoRoute(
          path: AppRoutes.dashboard,
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: DashboardScreen()),
        ),

        // ─── Transactions Tab ─────────────────────────────
        GoRoute(
          path: AppRoutes.transactions,
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: TransactionListScreen()),
        ),

        // ─── Savings Tab ──────────────────────────────────
        GoRoute(
          path: AppRoutes.savings,
          pageBuilder:
              (context, state) => const NoTransitionPage(
                child: Scaffold(
                  body: Center(child: Text('Savings - Coming Soon')),
                ),
              ),
        ),

        // ─── Settings Tab ─────────────────────────────────
        GoRoute(
          path: AppRoutes.settings,
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),

    // ─── Full Screen Routes (No Bottom Nav) ─────────────────
    GoRoute(
      path: AppRoutes.addTransaction,
      builder: (context, state) => const AddTransactionScreen(),
    ),
    GoRoute(
      path: AppRoutes.addSavingsGoal,
      builder: (context, state) => const AddSavingsGoalScreen(),
    ),
  ],
);
