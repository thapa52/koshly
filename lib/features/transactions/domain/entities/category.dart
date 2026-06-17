import 'transaction_type.dart';

/// Represents a transaction category.
///
/// Examples:
/// - Income categories: Salary, Freelance, Investments
/// - Expense categories: Food, Transport, Rent, Entertainment
///
/// Each category belongs to either income or expense.
/// Users can create custom categories.
class Category {
  /// Unique identifier for the category
  final String id;

  /// Display name of the category (e.g., "Food", "Salary")
  final String name;

  /// Icon code point from Material Icons
  /// Stored as int so it can be saved in Hive
  final int iconCode;

  /// Color value for the category
  /// Stored as int so it can be saved in Hive
  final int colorValue;

  /// Whether this is an income or expense category
  final TransactionType type;

  /// Whether this is a default category (cannot be deleted)
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  /// Creates a copy of this category with updated fields.
  /// Used when editing a category.
  ///
  /// Example:
  /// ```dart
  /// final updated = category.copyWith(name: 'Groceries');
  /// ```
  Category copyWith({
    String? id,
    String? name,
    int? iconCode,
    int? colorValue,
    TransactionType? type,
    bool? isDefault,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Category(id: $id, name: $name, type: $type)';
}
