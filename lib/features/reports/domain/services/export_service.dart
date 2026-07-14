import 'dart:io';

import '../../../transactions/domain/entities/transaction.dart';

// import 'package:koshly/features/transactions/domain/entities/transaction.dart';

/// Represents the result of an export operation.
///
/// Contains the generated file and its metadata.
class ExportResult {
  /// The generated file
  final File file;

  /// Display name of the file (e.g., "koshly_june_2025.csv")
  final String fileName;

  /// MIME type for sharing (e.g., "text/csv", "application/pdf")
  final String mimeType;

  const ExportResult({
    required this.file,
    required this.fileName,
    required this.mimeType,
  });
}

/// Abstract interface for exporting transaction data.
///
/// Implementations generate files in specific formats (CSV, PDF).
abstract class ExportService {
  /// Exports a list of transactions to a file.
  ///
  /// Parameters:
  /// - [transactions] — The data to export
  /// - [title] — Report title (e.g., "June 2025 Report")
  /// - [totalIncome] — Pre-calculated total income
  /// - [totalExpenses] — Pre-calculated total expenses
  ///
  /// Returns an [ExportResult] with the generated file.
  Future<ExportResult> exportTransactions({
    required List<Transaction> transactions,
    required String title,
    required double totalIncome,
    required double totalExpenses,
  });
}
