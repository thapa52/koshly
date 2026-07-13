import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../transactions/domain/entities/transaction.dart';
import '../../../transactions/domain/use_cases/get_transaction_summary.dart';
import '../../../transactions/presentation/providers/repository_provider.dart';
import '../../../transactions/presentation/providers/transaction_providers.dart';
import '../../data/services/csv_export_service.dart';
import '../../data/services/pdf_export_service.dart';
import '../../domain/services/export_service.dart';

/// Represents the currently selected report period.
class ReportPeriod {
  final int month;
  final int year;

  const ReportPeriod({required this.month, required this.year});

  /// Returns the first day of this period.
  DateTime get startDate => DateTime(year, month, 1);

  /// Returns the last day of this period.
  DateTime get endDate => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Returns a human-readable label.
  /// Example: "June 2025"
  String get label {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[month - 1]} $year';
  }

  /// Returns the previous month period.
  ReportPeriod get previous {
    if (month == 1) {
      return ReportPeriod(month: 12, year: year - 1);
    }
    return ReportPeriod(month: month - 1, year: year);
  }

  /// Returns the next month period.
  ReportPeriod get next {
    if (month == 12) {
      return ReportPeriod(month: 1, year: year + 1);
    }
    return ReportPeriod(month: month + 1, year: year);
  }

  /// Whether this period is the current month.
  bool get isCurrentMonth {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReportPeriod && other.month == month && other.year == year;
  }

  @override
  int get hashCode => Object.hash(month, year);
}

/// Manages the currently selected report period.
///
/// Defaults to the current month.
class ReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() {
    final now = DateTime.now();
    return ReportPeriod(month: now.month, year: now.year);
  }

  /// Navigates to the previous month.
  void goToPreviousMonth() {
    state = state.previous;
  }

  /// Navigates to the next month.
  void goToNextMonth() {
    state = state.next;
  }

  /// Jumps to a specific period.
  void goToPeriod(ReportPeriod period) {
    state = period;
  }

  /// Returns to the current month.
  void goToCurrentMonth() {
    final now = DateTime.now();
    state = ReportPeriod(month: now.month, year: now.year);
  }
}

/// Provider for [ReportPeriodNotifier].
final reportPeriodProvider =
    NotifierProvider<ReportPeriodNotifier, ReportPeriod>(
      ReportPeriodNotifier.new,
    );

/// Provides transactions filtered by the selected report period.
final reportTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((
  ref,
) {
  final period = ref.watch(reportPeriodProvider);
  final transactionsAsync = ref.watch(transactionNotifierProvider);

  return transactionsAsync.whenData((transactions) {
    return transactions.where((t) {
      return t.date.isAfter(
            period.startDate.subtract(const Duration(seconds: 1)),
          ) &&
          t.date.isBefore(period.endDate.add(const Duration(seconds: 1)));
    }).toList();
  });
});

/// Provides summary for the selected report period.
final reportSummaryProvider = FutureProvider<TransactionSummary>((ref) async {
  final period = ref.watch(reportPeriodProvider);
  final repository = ref.watch(transactionRepositoryProvider);
  final getTransactionSummary = GetTransactionSummary(repository);

  return getTransactionSummary.call(
    startDate: period.startDate,
    endDate: period.endDate,
  );
});

/// Provides the CSV export service.
final csvExportServiceProvider = Provider<ExportService>((ref) {
  return CsvExportService();
});

/// Provides the PDF export service.
final pdfExportServiceProvider = Provider<ExportService>((ref) {
  return PdfExportService();
});
