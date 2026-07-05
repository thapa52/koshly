import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/transaction_type.dart';
import 'repository_provider.dart';

/// Manages the state of all categories.
///
/// Automatically loads categories from Hive on first access.
/// Provides methods to add, update, and delete categories.
///
/// Usage in widgets:
/// ```dart
/// final categoriesAsync = ref.watch(categoryNotifierProvider);
/// categoriesAsync.when(
///   data: (categories) => ...,
///   loading: () => ...,
///   error: (e, st) => ...,
/// );
/// ```
class CategoryNotifier extends AsyncNotifier<List<Category>> {
  @override
  FutureOr<List<Category>> build() async {
    return _fetchCategories();
  }

  /// Fetches all categories from the repository.
  Future<List<Category>> _fetchCategories() async {
    final repository = ref.read(transactionRepositoryProvider);
    return repository.getAllCategories();
  }

  /// Adds a new category and refreshes the state.
  Future<void> addCategory(Category category) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.addCategory(category);

    // Refresh the state with updated list
    state = AsyncData(await _fetchCategories());
  }

  /// Updates an existing category and refreshes the state.
  Future<void> updateCategory(Category category) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.updateCategory(category);

    state = AsyncData(await _fetchCategories());
  }

  /// Deletes a category by ID and refreshes the state.
  ///
  /// Cannot delete default categories.
  /// Throws [ArgumentError] if trying to delete a default category.
  Future<void> deleteCategory(String id) async {
    final repository = ref.read(transactionRepositoryProvider);
    await repository.deleteCategory(id);

    state = AsyncData(await _fetchCategories());
  }
}

/// Provider for [CategoryNotifier].
final categoryNotifierProvider =
    AsyncNotifierProvider<CategoryNotifier, List<Category>>(
      CategoryNotifier.new,
    );

// ─── Derived Providers ──────────────────────────────────────────
// These are "computed" providers that filter the main category list.
// They automatically update when the main list changes.

/// Provides only income categories.
///
/// Usage:
/// ```dart
/// final incomeCategories = ref.watch(incomeCategoriesProvider);
/// ```
final incomeCategoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  final categoriesAsync = ref.watch(categoryNotifierProvider);

  return categoriesAsync.whenData(
    (categories) =>
        categories.where((c) => c.type == TransactionType.income).toList(),
  );
});

/// Provides only expense categories.
///
/// Usage:
/// ```dart
/// final expenseCategories = ref.watch(expenseCategoriesProvider);
/// ```
final expenseCategoriesProvider = Provider<AsyncValue<List<Category>>>((ref) {
  final categoriesAsync = ref.watch(categoryNotifierProvider);

  return categoriesAsync.whenData(
    (categories) =>
        categories.where((c) => c.type == TransactionType.expense).toList(),
  );
});
