import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../transactions/domain/entities/transaction.dart';
import '../../domain/services/export_service.dart';

/// PDF implementation of [ExportService].
///
/// Generates a professionally formatted .pdf report
/// with headers, summary tables, and transaction list.
class PdfExportService implements ExportService {
  @override
  Future<ExportResult> exportTransactions({
    required List<Transaction> transactions,
    required String title,
    required double totalIncome,
    required double totalExpenses,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32.0),
        header: (context) => _buildHeader(title),
        footer: (context) => _buildFooter(context),
        build:
            (context) => [
              _buildSummarySection(totalIncome, totalExpenses),
              pw.SizedBox(height: 24.0),
              _buildTransactionTable(transactions),
            ],
      ),
    );

    // ─── Write to File ───────────────────────────────────────
    final directory = await getApplicationDocumentsDirectory();
    final fileName = _generateFileName(title);
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return ExportResult(
      file: file,
      fileName: fileName,
      mimeType: 'application/pdf',
    );
  }

  /// Builds the page header.
  pw.Widget _buildHeader(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 12.0),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColor.fromInt(0xFF6C63FF),
            width: 2.0,
          ),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Koshly',
                style: pw.TextStyle(
                  fontSize: 22.0,
                  fontWeight: pw.FontWeight.bold,
                  color: const PdfColor.fromInt(0xFF6C63FF),
                ),
              ),
              pw.Text(
                'Personal Finance Dashboard',
                style: const pw.TextStyle(
                  fontSize: 10.0,
                  color: PdfColor.fromInt(0xFF6B7280),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 14.0,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Generated: ${DateFormatter.formatDate(DateTime.now())}',
                style: const pw.TextStyle(
                  fontSize: 9.0,
                  color: PdfColor.fromInt(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the page footer with page numbers.
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8.0),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          top: pw.BorderSide(color: PdfColor.fromInt(0xFFE5E7EB), width: 1.0),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Koshly — Personal Finance Dashboard',
            style: const pw.TextStyle(
              fontSize: 8.0,
              color: PdfColor.fromInt(0xFF9CA3AF),
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 8.0,
              color: PdfColor.fromInt(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the financial summary section.
  pw.Widget _buildSummarySection(double totalIncome, double totalExpenses) {
    final balance = totalIncome - totalExpenses;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16.0),
      decoration: pw.BoxDecoration(
        color: const PdfColor.fromInt(0xFFF8F9FA),
        borderRadius: pw.BorderRadius.circular(8.0),
        border: pw.Border.all(color: const PdfColor.fromInt(0xFFE5E7EB)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Financial Summary',
            style: pw.TextStyle(fontSize: 14.0, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 12.0),
          pw.Row(
            children: [
              _buildSummaryItem(
                'Total Income',
                CurrencyFormatter.format(totalIncome),
                const PdfColor.fromInt(0xFF2ECC71),
              ),
              pw.SizedBox(width: 16.0),
              _buildSummaryItem(
                'Total Expenses',
                CurrencyFormatter.format(totalExpenses),
                const PdfColor.fromInt(0xFFE74C3C),
              ),
              pw.SizedBox(width: 16.0),
              _buildSummaryItem(
                'Net Balance',
                CurrencyFormatter.format(balance),
                balance >= 0
                    ? const PdfColor.fromInt(0xFF2ECC71)
                    : const PdfColor.fromInt(0xFFE74C3C),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single summary item.
  pw.Widget _buildSummaryItem(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 9.0,
              color: PdfColor.fromInt(0xFF6B7280),
            ),
          ),
          pw.SizedBox(height: 4.0),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 14.0,
              fontWeight: pw.FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the transaction data table.
  pw.Widget _buildTransactionTable(List<Transaction> transactions) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transactions (${transactions.length})',
          style: pw.TextStyle(fontSize: 14.0, fontWeight: pw.FontWeight.bold),
        ),
        pw.SizedBox(height: 8.0),
        pw.Table(
          border: pw.TableBorder.all(
            color: const PdfColor.fromInt(0xFFE5E7EB),
            width: 0.5,
          ),
          columnWidths: {
            0: const pw.FlexColumnWidth(2.0),
            1: const pw.FlexColumnWidth(3.0),
            2: const pw.FlexColumnWidth(2.0),
            3: const pw.FlexColumnWidth(1.5),
            4: const pw.FlexColumnWidth(2.0),
          },
          children: [
            // ─── Table Header ──────────────────────────────
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF6C63FF),
              ),
              children: [
                _buildTableCell('Date', isHeader: true),
                _buildTableCell('Title', isHeader: true),
                _buildTableCell('Category', isHeader: true),
                _buildTableCell('Type', isHeader: true),
                _buildTableCell('Amount', isHeader: true),
              ],
            ),

            // ─── Table Rows ────────────────────────────────
            ...transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final transaction = entry.value;
              final isEven = index % 2 == 0;

              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color:
                      isEven
                          ? PdfColors.white
                          : const PdfColor.fromInt(0xFFF9FAFB),
                ),
                children: [
                  _buildTableCell(DateFormatter.formatDate(transaction.date)),
                  _buildTableCell(transaction.title),
                  _buildTableCell(transaction.category.name),
                  _buildTableCell(transaction.type.label),
                  _buildTableCell(
                    transaction.type.isIncome
                        ? '+${CurrencyFormatter.formatAmount(transaction.amount)}'
                        : '-${CurrencyFormatter.formatAmount(transaction.amount)}',
                    color:
                        transaction.type.isIncome
                            ? const PdfColor.fromInt(0xFF2ECC71)
                            : const PdfColor.fromInt(0xFFE74C3C),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  /// Builds a single table cell.
  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 9.0 : 8.5,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color:
              isHeader
                  ? PdfColors.white
                  : color ?? const PdfColor.fromInt(0xFF1A1A2E),
        ),
      ),
    );
  }

  /// Generates a clean file name from the report title.
  String _generateFileName(String title) {
    final sanitized = title
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return 'koshly_$sanitized.pdf';
  }
}
