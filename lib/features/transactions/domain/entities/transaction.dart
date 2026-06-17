import 'category.dart';
import 'transaction_type.dart';

/// Represents a single financial transaction.
///
/// This is the core entity of Koshly.
/// Every income or expense entry is stored as a Transaction.
///
/// Example:
/// ```dart
/// final transaction = Transaction(
///   id: 'abc-123',
///   title: 'Grocery Shopping',
///   amount: 45.50,
///   type: TransactionType.expense,
///   category: foodCategory,
///   date: DateTime.now(),
///   note: 'Weekly groceries from Walmart',
/// );
/// ```
class Transaction {
  /// Unique identifier for the transaction
  final String id;

  /// Short description of the transaction (e.g., "Grocery Shopping")
  final String title;

  /// Amount of money involved
  /// Always stored as a positive number.
  /// The [type] field determines if it's income or expense.
  final double amount;

  /// Whether this is income or expense
  final TransactionType type;

  /// The category this transaction belongs to
  final Category category;

  /// Date and time when the transaction occurred
  final DateTime date;

  /// Optional note for additional details
  final String? note;

  /// When this transaction was created in the app
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    required this.createdAt,
  });

  /// Creates a copy of this transaction with updated fields.
  /// Used when editing a transaction.
  ///
  /// Example:
  /// ```dart
  /// final updated = transaction.copyWith(amount: 50.0);
  /// ```
  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    Category? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Returns the signed amount.
  /// Positive for income, negative for expense.
  /// Used in calculations like total balance.
  double get signedAmount {
    return type.isIncome ? amount : -amount;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Transaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Transaction(id: $id, title: $title, amount: $amount, type: $type)';
}
