import 'package:flutter/material.dart';
import 'package:koshly/core/theme/app_colors.dart';
import 'package:koshly/features/transactions/domain/entities/category.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';

/// Provides default categories for first-time app setup.
///
/// These categories are seeded into the database when
/// the app launches for the first time.
///
/// Users cannot delete default categories.
class DefaultCategories {
  // Private constructor to prevent instantiation
  DefaultCategories._();

  /// Default income categories
  static List<Category> get incomeCategories => [
    Category(
      id: 'default-income-salary',
      name: 'Salary',
      iconCode: Icons.account_balance_wallet.codePoint,
      colorValue: AppColors.income.toARGB32(),
      type: TransactionType.income,
      isDefault: true,
    ),
    Category(
      id: 'default-income-freelance',
      name: 'Freelance',
      iconCode: Icons.laptop_mac.codePoint,
      colorValue: AppColors.categoryColors[0].toARGB32(),
      type: TransactionType.income,
      isDefault: true,
    ),
    Category(
      id: 'default-income-investments',
      name: 'Investments',
      iconCode: Icons.trending_up.codePoint,
      colorValue: AppColors.categoryColors[3].toARGB32(),
      type: TransactionType.income,
      isDefault: true,
    ),
    Category(
      id: 'default-income-gifts',
      name: 'Gifts',
      iconCode: Icons.card_giftcard.codePoint,
      colorValue: AppColors.categoryColors[9].toARGB32(),
      type: TransactionType.income,
      isDefault: true,
    ),
    Category(
      id: 'default-income-other',
      name: 'Other Income',
      iconCode: Icons.attach_money.codePoint,
      colorValue: AppColors.categoryColors[6].toARGB32(),
      type: TransactionType.income,
      isDefault: true,
    ),
  ];

  /// Default expense categories
  static List<Category> get expenseCategories => [
    Category(
      id: 'default-expense-food',
      name: 'Food & Dining',
      iconCode: Icons.restaurant.codePoint,
      colorValue: AppColors.categoryColors[4].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-transport',
      name: 'Transport',
      iconCode: Icons.directions_car.codePoint,
      colorValue: AppColors.categoryColors[3].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-shopping',
      name: 'Shopping',
      iconCode: Icons.shopping_bag.codePoint,
      colorValue: AppColors.categoryColors[9].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-bills',
      name: 'Bills & Utilities',
      iconCode: Icons.receipt_long.codePoint,
      colorValue: AppColors.categoryColors[2].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-entertainment',
      name: 'Entertainment',
      iconCode: Icons.movie.codePoint,
      colorValue: AppColors.categoryColors[5].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-health',
      name: 'Health',
      iconCode: Icons.local_hospital.codePoint,
      colorValue: AppColors.expense.toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-education',
      name: 'Education',
      iconCode: Icons.school.codePoint,
      colorValue: AppColors.categoryColors[0].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-rent',
      name: 'Rent',
      iconCode: Icons.home.codePoint,
      colorValue: AppColors.categoryColors[8].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-travel',
      name: 'Travel',
      iconCode: Icons.flight.codePoint,
      colorValue: AppColors.categoryColors[10].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
    Category(
      id: 'default-expense-other',
      name: 'Other Expense',
      iconCode: Icons.more_horiz.codePoint,
      colorValue: AppColors.categoryColors[7].toARGB32(),
      type: TransactionType.expense,
      isDefault: true,
    ),
  ];

  /// All default categories (income + expense)
  static List<Category> get all => [...incomeCategories, ...expenseCategories];
}
