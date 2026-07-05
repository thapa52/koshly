/// Represents the type of a financial transaction.
///
/// Every transaction must be either:
/// - [income] → Money coming in (salary, freelance, gifts)
/// - [expense] → Money going out (rent, food, bills)
enum TransactionType {
  income('Income'),
  expense('Expense');

  /// Human-readable label for display in UI
  final String label;

  const TransactionType(this.label);

  /// Returns true if this is an income transaction
  bool get isIncome => this == TransactionType.income;

  /// Returns true if this is an expense transaction
  bool get isExpense => this == TransactionType.expense;
}
