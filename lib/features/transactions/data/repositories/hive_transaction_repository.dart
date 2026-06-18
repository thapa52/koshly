import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import '../sources/default_categories.dart';

/// Hive implementation of [TransactionRepository].
///
/// This class is the only place where Hive code exists.
/// The rest of the app interacts with [TransactionRepository] interface.
///
/// Responsibilities:
/// - Open and manage Hive boxes
/// - Convert between Model ↔ Entity
/// - Seed default categories on first launch
/// - Handle all CRUD operations
/// - Calculate totals and filtered queries
class HiveTransactionRepository implements TransactionRepository {
  /// Hive box for storing transactions
  late Box<TransactionModel> _transactionBox;

  /// Hive box for storing categories
  late Box<CategoryModel> _categoryBox;

  /// Whether the repository has been initialized
  bool _isInitialized = false;

  /// Initializes the repository by opening Hive boxes
  /// and seeding default categories if needed.
  ///
  /// Must be called before any other method.
  Future<void> init() async {
    if (_isInitialized) return;

    // Register adapters if not already registered
    if (!Hive.isAdapterRegistered(AppConstants.categoryTypeId)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(AppConstants.transactionTypeId)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }

    // Open boxes
    _categoryBox = await Hive.openBox<CategoryModel>(AppConstants.categoryBox);
    _transactionBox = await Hive.openBox<TransactionModel>(
      AppConstants.transactionBox,
    );

    // Seed default categories on first launch
    await _seedDefaultCategoriesIfNeeded();

    _isInitialized = true;
  }

  /// Seeds default categories if the category box is empty.
  Future<void> _seedDefaultCategoriesIfNeeded() async {
    if (_categoryBox.isEmpty) {
      final defaultCategories = DefaultCategories.all;
      for (final category in defaultCategories) {
        final model = CategoryModel.fromEntity(category);
        await _categoryBox.put(category.id, model);
      }
    }
  }

  /// Ensures the repository is initialized before use.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'HiveTransactionRepository is not initialized. Call init() first.',
      );
    }
  }

  // ─── Transaction Operations ──────────────────────────────────

  @override
  Future<List<Transaction>> getAllTransactions() async {
    _ensureInitialized();

    final models = _transactionBox.values.toList();

    // Sort by date (newest first)
    models.sort((a, b) => b.date.compareTo(a.date));

    return _modelsToEntities(models);
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    _ensureInitialized();

    final model = _transactionBox.get(id);
    if (model == null) return null;

    final category = await _getCategoryById(model.categoryId);
    if (category == null) return null;

    return model.toEntity(category);
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    _ensureInitialized();

    final models =
        _transactionBox.values.where((model) {
          return model.date.isAfter(
                startDate.subtract(const Duration(days: 1)),
              ) &&
              model.date.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();

    // Sort by date (newest first)
    models.sort((a, b) => b.date.compareTo(a.date));

    return _modelsToEntities(models);
  }

  @override
  Future<List<Transaction>> getTransactionsByCategory(String categoryId) async {
    _ensureInitialized();

    final models =
        _transactionBox.values.where((model) {
          return model.categoryId == categoryId;
        }).toList();

    // Sort by date (newest first)
    models.sort((a, b) => b.date.compareTo(a.date));

    return _modelsToEntities(models);
  }

  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    _ensureInitialized();

    final models =
        _transactionBox.values.where((model) {
          return model.typeIndex == type.index;
        }).toList();

    // Sort by date (newest first)
    models.sort((a, b) => b.date.compareTo(a.date));

    return _modelsToEntities(models);
  }

  @override
  Future<Transaction> addTransaction(Transaction transaction) async {
    _ensureInitialized();

    final model = TransactionModel.fromEntity(transaction);
    await _transactionBox.put(transaction.id, model);

    return transaction;
  }

  @override
  Future<Transaction> updateTransaction(Transaction transaction) async {
    _ensureInitialized();

    final model = TransactionModel.fromEntity(transaction);
    await _transactionBox.put(transaction.id, model);

    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _ensureInitialized();

    await _transactionBox.delete(id);
  }

  @override
  Future<double> getTotalIncome({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();

    final transactions =
        startDate != null && endDate != null
            ? await getTransactionsByDateRange(
              startDate: startDate,
              endDate: endDate,
            )
            : await getAllTransactions();

    return transactions
        .where((t) => t.type.isIncome)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _ensureInitialized();

    final transactions =
        startDate != null && endDate != null
            ? await getTransactionsByDateRange(
              startDate: startDate,
              endDate: endDate,
            )
            : await getAllTransactions();

    return transactions
        .where((t) => t.type.isExpense)
        .fold<double>(0.0, (sum, t) => sum + t.amount);
  }

  @override
  Future<double> getBalance({DateTime? startDate, DateTime? endDate}) async {
    final income = await getTotalIncome(startDate: startDate, endDate: endDate);
    final expenses = await getTotalExpenses(
      startDate: startDate,
      endDate: endDate,
    );

    return income - expenses;
  }

  // ─── Category Operations ──────────────────────────────────────

  @override
  Future<List<Category>> getAllCategories() async {
    _ensureInitialized();

    return _categoryBox.values.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Category>> getCategoriesByType(TransactionType type) async {
    _ensureInitialized();

    return _categoryBox.values
        .where((model) => model.typeIndex == type.index)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  Future<Category> addCategory(Category category) async {
    _ensureInitialized();

    final model = CategoryModel.fromEntity(category);
    await _categoryBox.put(category.id, model);

    return category;
  }

  @override
  Future<Category> updateCategory(Category category) async {
    _ensureInitialized();

    final model = CategoryModel.fromEntity(category);
    await _categoryBox.put(category.id, model);

    return category;
  }

  @override
  Future<void> deleteCategory(String id) async {
    _ensureInitialized();

    final category = _categoryBox.get(id);
    if (category != null && category.isDefault) {
      throw ArgumentError('Cannot delete default categories.');
    }

    await _categoryBox.delete(id);
  }

  // ─── Private Helper Methods ───────────────────────────────────

  /// Converts a list of models to entities.
  Future<List<Transaction>> _modelsToEntities(
    List<TransactionModel> models,
  ) async {
    final transactions = <Transaction>[];

    for (final model in models) {
      final category = await _getCategoryById(model.categoryId);
      if (category != null) {
        transactions.add(model.toEntity(category));
      }
    }

    return transactions;
  }

  /// Gets a category by its ID.
  Future<Category?> _getCategoryById(String id) async {
    final model = _categoryBox.get(id);
    return model?.toEntity();
  }
}
