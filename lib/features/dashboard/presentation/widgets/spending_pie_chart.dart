import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/dashboard_providers.dart';

/// Displays a pie chart showing spending breakdown by category.
///
/// Uses FL Chart for rendering.
/// Data is provided by [categorySpendingProvider].
///
/// Usage:
/// ```dart
/// const SpendingPieChart()
/// ```
class SpendingPieChart extends ConsumerWidget {
  const SpendingPieChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendingAsync = ref.watch(categorySpendingProvider);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Title ──────────────────────────────────────────
          Text(
            'Spending Breakdown',
            style: AppTextStyles.headlineMedium.copyWith(color: onSurface),
          ),
          const SizedBox(height: 20.0),

          // ─── Chart Content ──────────────────────────────────
          spendingAsync.when(
            loading:
                () => const SizedBox(
                  height: 200.0,
                  child: Center(child: CircularProgressIndicator()),
                ),
            error:
                (e, st) => SizedBox(
                  height: 200.0,
                  child: Center(
                    child: Text(
                      'Unable to load chart',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
            data: (spending) {
              if (spending.isEmpty) {
                return SizedBox(
                  height: 200.0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pie_chart_outline,
                          size: 48.0,
                          color: onSurface.withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'No expenses yet',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // ─── Pie Chart ──────────────────────────────
                  SizedBox(
                    height: 200.0,
                    child: PieChart(
                      PieChartData(
                        sections:
                            spending.map((item) {
                              return PieChartSectionData(
                                value: item.amount,
                                color: Color(item.colorValue),
                                radius: 45.0,
                                title: '${item.percentage.toStringAsFixed(0)}%',
                                titleStyle: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                titlePositionPercentageOffset: 0.55,
                              );
                            }).toList(),
                        sectionsSpace: 2.0,
                        centerSpaceRadius: 40.0,
                        startDegreeOffset: -90,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  // ─── Legend ──────────────────────────────────
                  ...spending.map((item) {
                    return _buildLegendItem(
                      context: context,
                      name: item.categoryName,
                      color: Color(item.colorValue),
                      amount: item.amount,
                      percentage: item.percentage,
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds a single legend item below the pie chart.
  Widget _buildLegendItem({
    required BuildContext context,
    required String name,
    required Color color,
    required double amount,
    required double percentage,
  }) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Color indicator
          Container(
            width: 12.0,
            height: 12.0,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3.0),
            ),
          ),
          const SizedBox(width: 10.0),

          // Category name
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(color: onSurface),
            ),
          ),

          // Amount
          Text(
            CurrencyFormatter.format(amount),
            style: AppTextStyles.labelLarge.copyWith(color: onSurface),
          ),
          const SizedBox(width: 8.0),

          // Percentage
          SizedBox(
            width: 45.0,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: AppTextStyles.labelSmall.copyWith(
                color: onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
