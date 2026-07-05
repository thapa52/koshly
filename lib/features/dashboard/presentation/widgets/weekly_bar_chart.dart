import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../providers/dashboard_providers.dart';

/// Displays a bar chart showing daily spending for the current week.
///
/// Uses FL Chart for rendering.
/// Data is provided by [weeklySpendingProvider].
///
/// Usage:
/// ```dart
/// const WeeklyBarChart()
/// ```
class WeeklyBarChart extends ConsumerWidget {
  const WeeklyBarChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weeklyAsync = ref.watch(weeklySpendingProvider);
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
            'This Week',
            style: AppTextStyles.headlineMedium.copyWith(color: onSurface),
          ),
          const SizedBox(height: 24.0),

          // ─── Chart Content ──────────────────────────────────
          weeklyAsync.when(
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
            data: (weeklyData) {
              final hasData = weeklyData.any((d) => d.amount > 0);

              if (!hasData) {
                return SizedBox(
                  height: 200.0,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bar_chart,
                          size: 48.0,
                          color: onSurface.withValues(alpha: 0.25),
                        ),
                        const SizedBox(height: 12.0),
                        Text(
                          'No spending this week',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return _buildBarChart(context, weeklyData);
            },
          ),
        ],
      ),
    );
  }

  /// Builds the actual bar chart widget.
  Widget _buildBarChart(BuildContext context, List<DailySpending> weeklyData) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    // Find the maximum amount to set the Y axis
    final maxAmount = weeklyData
        .map((d) => d.amount)
        .reduce((a, b) => a > b ? a : b);

    // Add 20% padding to the top of the chart
    final maxY = maxAmount * 1.2;

    return SizedBox(
      height: 200.0,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY > 0 ? maxY : 100,
          minY: 0,

          // ─── Grid Lines ─────────────────────────────────
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY > 0 ? maxY / 4 : 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: onSurface.withValues(alpha: 0.08),
                strokeWidth: 1.0,
              );
            },
          ),

          // ─── Border ─────────────────────────────────────
          borderData: FlBorderData(show: false),

          // ─── X Axis (Day Labels) ────────────────────────
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 50.0,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      CurrencyFormatter.formatCompact(value),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= weeklyData.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      weeklyData[index].dayLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ─── Bar Groups ─────────────────────────────────
          barGroups:
              weeklyData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final isToday = index == (DateTime.now().weekday - 1);

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: data.amount > 0 ? data.amount : 0,
                      color:
                          isToday
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.4),
                      width: 16.0,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(6.0),
                        topRight: Radius.circular(6.0),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY > 0 ? maxY : 100,
                        color: onSurface.withValues(alpha: 0.04),
                      ),
                    ),
                  ],
                );
              }).toList(),

          // ─── Touch Tooltip ──────────────────────────────
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Theme.of(context).colorScheme.surface,
              tooltipBorder: BorderSide(color: Theme.of(context).dividerColor),

              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final day = weeklyData[group.x].dayLabel;
                final amount = rod.toY;

                return BarTooltipItem(
                  '$day\n',
                  AppTextStyles.labelSmall.copyWith(
                    color: onSurface.withValues(alpha: 0.6),
                  ),
                  children: [
                    TextSpan(
                      text: CurrencyFormatter.format(amount),
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
