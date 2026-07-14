import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/services/export_service.dart';

/// CSV implementation of [ExportService].
///
/// Generates a .csv file that can be opened in
/// Excel, Google Sheets, or any spreadsheet app.
class CsvExportService implements ExportService {
  @override
  Future<ExportResult> exportTransactions({
    required List<Transaction> transactions,
    required String title,
    required double totalIncome,
    required double totalExpenses,
  }) async {
    // ─── Build CSV Rows ─────────────────────────────────────
    final rows = <List<dynamic>>[];

    // Header row
    rows.add(['Date', 'Title', 'Category', 'Type', 'Amount', 'Note']);

    // Data rows
    for (final transaction in transactions) {
      rows.add([
        DateFormatter.formatDate(transaction.date),
        transaction.title,
        transaction.category.name,
        transaction.type.label,
        transaction.type.isIncome ? transaction.amount : -transaction.amount,
        transaction.note ?? '',
      ]);
    }

    // Summary rows
    rows.add([]);
    rows.add(['Summary', '', '', '', '', '']);
    rows.add(['Total Income', '', '', '', totalIncome, '']);
    rows.add(['Total Expenses', '', '', '', -totalExpenses, '']);
    rows.add(['Net Balance', '', '', '', totalIncome - totalExpenses, '']);

    // ─── Convert to CSV String ───────────────────────────────
    final csvData = const ListToCsvConverter().convert(rows);

    // ─── Write to File ───────────────────────────────────────
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateFileName(title);
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(csvData);

    return ExportResult(file: file, fileName: fileName, mimeType: 'text/csv');
  }

  /// Generates a clean file name from the report title.
  ///
  /// Example: "June 2025 Report" → "koshly_june_2025_report.csv"
  String _generateFileName(String title) {
    final sanitized = title
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return 'koshly_$sanitized.csv';
  }
}
