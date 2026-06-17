import '../repositories/transaction_repository.dart';

/// Immutable result returned by [GetTransactionSummary].
///
/// Represents a financial snapshot for a given period.
class TransactionSummary {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int transactionCount;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.transactionCount,
    this.startDate,
    this.endDate,
  });

  /// Whether there are any transactions in this summary period.
  bool get hasTransactions => transactionCount > 0;

  /// Whether the balance is positive or zero.
  bool get isPositiveBalance => balance >= 0;

  @override
  String toString() {
    return 'TransactionSummary('
        'totalIncome: $totalIncome, '
        'totalExpenses: $totalExpenses, '
        'balance: $balance, '
        'transactionCount: $transactionCount, '
        'startDate: $startDate, '
        'endDate: $endDate'
        ')';
  }
}

/// Use case to calculate a transaction summary for a given period.
///
/// Returns:
/// - total income
/// - total expenses
/// - net balance
/// - number of transactions
class GetTransactionSummary {
  final TransactionRepository _repository;

  const GetTransactionSummary(this._repository);

  /// Returns a summary for all transactions if no date range is provided.
  ///
  /// If filtering by date, both [startDate] and [endDate] must be provided.
  ///
  /// Throws [ArgumentError] if:
  /// - only one date is provided
  /// - start date is after end date
  Future<TransactionSummary> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final bool hasOnlyOneDate =
        (startDate == null && endDate != null) ||
        (startDate != null && endDate == null);

    if (hasOnlyOneDate) {
      throw ArgumentError(
        'Both startDate and endDate must be provided together.',
      );
    }

    if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
      throw ArgumentError('Start date cannot be after end date.');
    }

    final transactions =
        startDate != null && endDate != null
            ? await _repository.getTransactionsByDateRange(
              startDate: startDate,
              endDate: endDate,
            )
            : await _repository.getAllTransactions();

    final totalIncome = await _repository.getTotalIncome(
      startDate: startDate,
      endDate: endDate,
    );

    final totalExpenses = await _repository.getTotalExpenses(
      startDate: startDate,
      endDate: endDate,
    );

    // We calculate balance here to keep one source of truth
    // for this summary response.
    final balance = totalIncome - totalExpenses;

    return TransactionSummary(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      balance: balance,
      transactionCount: transactions.length,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
