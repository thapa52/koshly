import 'dart:io';

import 'package:flutter/services.dart';
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
    // ─── Load Fonts ─────────────────────────────────────────
    final regularFont = await _loadFont('Roboto-Regular.ttf');
    final boldFont = await _loadFont('Roboto-Bold.ttf');

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32.0),
        theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        header: (context) => _buildHeader(title, boldFont, regularFont),
        footer: (context) => _buildFooter(context, regularFont),
        build:
            (context) => [
              _buildSummarySection(
                totalIncome,
                totalExpenses,
                boldFont,
                regularFont,
              ),
              pw.SizedBox(height: 24.0),
              _buildTransactionTable(transactions, boldFont, regularFont),
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

  /// Loads a font from Flutter assets.
  Future<pw.Font> _loadFont(String fontName) async {
    final fontData = await rootBundle.load('assets/fonts/$fontName');
    return pw.Font.ttf(fontData);
  }

  /// Builds the page header.
  pw.Widget _buildHeader(String title, pw.Font boldFont, pw.Font regularFont) {
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
                  font: boldFont,
                  fontSize: 22.0,
                  color: const PdfColor.fromInt(0xFF6C63FF),
                ),
              ),
              pw.Text(
                'Personal Finance Dashboard',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 10.0,
                  color: const PdfColor.fromInt(0xFF6B7280),
                ),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(font: boldFont, fontSize: 14.0),
              ),
              pw.Text(
                'Generated: ${DateFormatter.formatDate(DateTime.now())}',
                style: pw.TextStyle(
                  font: regularFont,
                  fontSize: 9.0,
                  color: const PdfColor.fromInt(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the page footer.
  pw.Widget _buildFooter(pw.Context context, pw.Font regularFont) {
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
            'Koshly - Personal Finance Dashboard',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8.0,
              color: const PdfColor.fromInt(0xFF9CA3AF),
            ),
          ),
          pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 8.0,
              color: const PdfColor.fromInt(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the financial summary section.
  pw.Widget _buildSummarySection(
    double totalIncome,
    double totalExpenses,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
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
            style: pw.TextStyle(font: boldFont, fontSize: 14.0),
          ),
          pw.SizedBox(height: 12.0),
          pw.Row(
            children: [
              _buildSummaryItem(
                'Total Income',
                CurrencyFormatter.format(totalIncome),
                const PdfColor.fromInt(0xFF2ECC71),
                boldFont,
                regularFont,
              ),
              pw.SizedBox(width: 16.0),
              _buildSummaryItem(
                'Total Expenses',
                CurrencyFormatter.format(totalExpenses),
                const PdfColor.fromInt(0xFFE74C3C),
                boldFont,
                regularFont,
              ),
              pw.SizedBox(width: 16.0),
              _buildSummaryItem(
                'Net Balance',
                CurrencyFormatter.format(balance),
                balance >= 0
                    ? const PdfColor.fromInt(0xFF2ECC71)
                    : const PdfColor.fromInt(0xFFE74C3C),
                boldFont,
                regularFont,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a single summary item.
  pw.Widget _buildSummaryItem(
    String label,
    String value,
    PdfColor color,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9.0,
              color: const PdfColor.fromInt(0xFF6B7280),
            ),
          ),
          pw.SizedBox(height: 4.0),
          pw.Text(
            value,
            style: pw.TextStyle(font: boldFont, fontSize: 14.0, color: color),
          ),
        ],
      ),
    );
  }

  /// Builds the transaction data table.
  pw.Widget _buildTransactionTable(
    List<Transaction> transactions,
    pw.Font boldFont,
    pw.Font regularFont,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Transactions (${transactions.length})',
          style: pw.TextStyle(font: boldFont, fontSize: 14.0),
        ),
        pw.SizedBox(height: 8.0),
        pw.Table(
          border: pw.TableBorder.all(
            color: const PdfColor.fromInt(0xFFE5E7EB),
            width: 0.5,
          ),
          columnWidths: const {
            0: pw.FlexColumnWidth(2.0),
            1: pw.FlexColumnWidth(3.0),
            2: pw.FlexColumnWidth(2.0),
            3: pw.FlexColumnWidth(1.5),
            4: pw.FlexColumnWidth(2.0),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF6C63FF),
              ),
              children: [
                _buildTableCell('Date', boldFont, regularFont, isHeader: true),
                _buildTableCell('Title', boldFont, regularFont, isHeader: true),
                _buildTableCell(
                  'Category',
                  boldFont,
                  regularFont,
                  isHeader: true,
                ),
                _buildTableCell('Type', boldFont, regularFont, isHeader: true),
                _buildTableCell(
                  'Amount',
                  boldFont,
                  regularFont,
                  isHeader: true,
                ),
              ],
            ),
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
                  _buildTableCell(
                    DateFormatter.formatDate(transaction.date),
                    boldFont,
                    regularFont,
                  ),
                  _buildTableCell(transaction.title, boldFont, regularFont),
                  _buildTableCell(
                    transaction.category.name,
                    boldFont,
                    regularFont,
                  ),
                  _buildTableCell(
                    transaction.type.label,
                    boldFont,
                    regularFont,
                  ),
                  _buildTableCell(
                    transaction.type.isIncome
                        ? '+${CurrencyFormatter.formatAmount(transaction.amount)}'
                        : '-${CurrencyFormatter.formatAmount(transaction.amount)}',
                    boldFont,
                    regularFont,
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
    String text,
    pw.Font boldFont,
    pw.Font regularFont, {
    bool isHeader = false,
    PdfColor? color,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: isHeader ? boldFont : regularFont,
          fontSize: isHeader ? 9.0 : 8.5,
          color:
              isHeader
                  ? PdfColors.white
                  : color ?? const PdfColor.fromInt(0xFF1A1A2E),
        ),
      ),
    );
  }

  /// Generates a clean file name.
  String _generateFileName(String title) {
    final sanitized = title
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp(r'[^a-z0-9_]'), '');
    return 'koshly_$sanitized.pdf';
  }
}
