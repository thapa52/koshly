import 'package:koshly/features/transactions/domain/entities/category.dart';
import 'package:koshly/features/transactions/domain/entities/transaction.dart';
import 'package:koshly/features/transactions/domain/entities/transaction_type.dart';

/// Provides reusable test data for all test files.
///
/// Usage:
/// ```dart
/// import 'package:koshly/test/helpers/test_data.dart';
///
/// final category = TestData.salaryCategory;
/// final transaction = TestData.salaryTransaction;
/// ```
class TestData {
  TestData._();

  // ─── Categories ──────────────────────────────────────────────

  static const Category salaryCategory = Category(
    id: 'cat-salary',
    name: 'Salary',
    iconCode: 0xe559,
    colorValue: 0xFF2ECC71,
    type: TransactionType.income,
    isDefault: true,
  );

  static const Category freelanceCategory = Category(
    id: 'cat-freelance',
    name: 'Freelance',
    iconCode: 0xe321,
    colorValue: 0xFF6C63FF,
    type: TransactionType.income,
    isDefault: false,
  );

  static const Category foodCategory = Category(
    id: 'cat-food',
    name: 'Food & Dining',
    iconCode: 0xe532,
    colorValue: 0xFFF39C12,
    type: TransactionType.expense,
    isDefault: true,
  );

  static const Category transportCategory = Category(
    id: 'cat-transport',
    name: 'Transport',
    iconCode: 0xe1d7,
    colorValue: 0xFF3498DB,
    type: TransactionType.expense,
    isDefault: true,
  );

  static const Category shoppingCategory = Category(
    id: 'cat-shopping',
    name: 'Shopping',
    iconCode: 0xf37d,
    colorValue: 0xFFE91E63,
    type: TransactionType.expense,
    isDefault: false,
  );

  /// All test categories
  static List<Category> get allCategories => [
    salaryCategory,
    freelanceCategory,
    foodCategory,
    transportCategory,
    shoppingCategory,
  ];

  /// Only income categories
  static List<Category> get incomeCategories => [
    salaryCategory,
    freelanceCategory,
  ];

  /// Only expense categories
  static List<Category> get expenseCategories => [
    foodCategory,
    transportCategory,
    shoppingCategory,
  ];

  // ─── Transactions ────────────────────────────────────────────

  static Transaction salaryTransaction = Transaction(
    id: 'txn-salary',
    title: 'Monthly Salary',
    amount: 5000.00,
    type: TransactionType.income,
    category: salaryCategory,
    date: DateTime(2025, 6, 1),
    note: 'June salary',
    createdAt: DateTime(2025, 6, 1),
  );

  static Transaction freelanceTransaction = Transaction(
    id: 'txn-freelance',
    title: 'Website Project',
    amount: 1500.00,
    type: TransactionType.income,
    category: freelanceCategory,
    date: DateTime(2025, 6, 5),
    createdAt: DateTime(2025, 6, 5),
  );

  static Transaction groceryTransaction = Transaction(
    id: 'txn-grocery',
    title: 'Grocery Shopping',
    amount: 85.50,
    type: TransactionType.expense,
    category: foodCategory,
    date: DateTime(2025, 6, 3),
    note: 'Weekly groceries',
    createdAt: DateTime(2025, 6, 3),
  );

  static Transaction busTransaction = Transaction(
    id: 'txn-bus',
    title: 'Bus Pass',
    amount: 50.00,
    type: TransactionType.expense,
    category: transportCategory,
    date: DateTime(2025, 6, 2),
    createdAt: DateTime(2025, 6, 2),
  );

  static Transaction shoppingTransaction = Transaction(
    id: 'txn-shopping',
    title: 'New Shoes',
    amount: 120.00,
    type: TransactionType.expense,
    category: shoppingCategory,
    date: DateTime(2025, 6, 4),
    createdAt: DateTime(2025, 6, 4),
  );

  /// All test transactions
  static List<Transaction> get allTransactions => [
    salaryTransaction,
    freelanceTransaction,
    groceryTransaction,
    busTransaction,
    shoppingTransaction,
  ];

  /// Only income transactions
  static List<Transaction> get incomeTransactions => [
    salaryTransaction,
    freelanceTransaction,
  ];

  /// Only expense transactions
  static List<Transaction> get expenseTransactions => [
    groceryTransaction,
    busTransaction,
    shoppingTransaction,
  ];

  // ─── Computed Values ─────────────────────────────────────────

  /// Total income from all test transactions
  static double get totalIncome => 5000.00 + 1500.00;

  /// Total expenses from all test transactions
  static double get totalExpenses => 85.50 + 50.00 + 120.00;

  /// Net balance from all test transactions
  static double get balance => totalIncome - totalExpenses;

  /// Total number of test transactions
  static int get transactionCount => allTransactions.length;
}
