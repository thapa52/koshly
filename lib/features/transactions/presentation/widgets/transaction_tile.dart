import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/transaction.dart';

/// A reusable widget that displays a single transaction as a list tile.
///
/// Shows:
/// - Category icon with colored background
/// - Transaction title
/// - Category name
/// - Relative date
/// - Amount (green for income, red for expense)
///
/// Usage:
/// ```dart
/// TransactionTile(
///   transaction: myTransaction,
///   onTap: () => navigateToEdit(myTransaction),
/// )
/// ```
class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionTile({super.key, required this.transaction, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type.isIncome;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            _buildCategoryIcon(),
            const SizedBox(width: 14.0),
            Expanded(child: _buildTitleSection(context)),
            const SizedBox(width: 12.0),
            _buildAmountSection(context, isIncome),
          ],
        ),
      ),
    );
  }

  /// Builds the circular category icon with colored background.
  Widget _buildCategoryIcon() {
    final categoryColor = Color(transaction.category.colorValue);

    return Container(
      width: 48.0,
      height: 48.0,
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Icon(
        IconData(transaction.category.iconCode, fontFamily: 'MaterialIcons'),
        color: categoryColor,
        size: 22.0,
      ),
    );
  }

  /// Builds the title and category name section.
  Widget _buildTitleSection(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          transaction.title,
          style: AppTextStyles.headlineSmall.copyWith(color: onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4.0),
        Text(
          transaction.category.name,
          style: AppTextStyles.bodySmall.copyWith(
            color: onSurface.withValues(alpha: 0.6),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Builds the amount and date section.
  Widget _buildAmountSection(BuildContext context, bool isIncome) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${isIncome ? '+' : '-'}${CurrencyFormatter.formatAmount(transaction.amount)}',
          style: AppTextStyles.amountSmall.copyWith(
            color: isIncome ? AppColors.income : AppColors.expense,
          ),
        ),
        const SizedBox(height: 4.0),
        Text(
          DateFormatter.formatRelative(transaction.date),
          style: AppTextStyles.labelSmall.copyWith(
            color: onSurface.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
