import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';

/// A selectable chip widget that displays a transaction category.
///
/// Used in the Add Transaction form for category selection.
///
/// Usage:
/// ```dart
/// CategoryChip(
///   category: foodCategory,
///   isSelected: selectedCategory == foodCategory,
///   onTap: () => setState(() => selectedCategory = foodCategory),
/// )
/// ```
class CategoryChip extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = Color(category.colorValue);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? categoryColor.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: isSelected ? categoryColor : Theme.of(context).dividerColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Category Icon ─────────────────────────────
            Icon(
              IconData(category.iconCode, fontFamily: 'MaterialIcons'),
              color:
                  isSelected
                      ? categoryColor
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
              size: 16.0,
            ),
            const SizedBox(width: 6.0),

            // ─── Category Name ─────────────────────────────
            Text(
              category.name,
              style: AppTextStyles.labelMedium.copyWith(
                color:
                    isSelected
                        ? categoryColor
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
