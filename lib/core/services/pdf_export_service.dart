import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../data/models/screening_answer_row.dart';
import '../../data/models/screening_result.dart';

class PdfExportService {
  static Future<Uint8List> generateScreeningReport(
    ScreeningResult result,
    List<ScreeningAnswerRow> rows,
  ) async {
    final pdf = pw.Document();
    final formattedDate = '${result.date.day}/${result.date.month}/${result.date.year}';
    final isAdhd = result.type == ScreeningResult.typeADHD;
    final screeningLabel = isAdhd ? 'Vanderbilt ADHD' : 'M-CHAT-R Autism';

    // Standard styling setup
    final headerColor = PdfColors.teal800;
    final isHighRisk = result.riskLevel.contains('HIGH');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header Title
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DEVELOPMENTAL SCREENING REPORT',
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: headerColor),
                    ),
                    pw.Text(
                      'Tala ng Obserbasyon ng Magulang',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Text('Petsa: $formattedDate', style: const pw.TextStyle(fontSize: 11)),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Divider(color: PdfColors.grey400),
            pw.SizedBox(height: 16),

            // Result Summary Box
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: isHighRisk ? PdfColors.red50 : PdfColors.green50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: isHighRisk ? PdfColors.red400 : PdfColors.green400),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Uri ng Screening: $screeningLabel',
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Kategorya: ${result.riskLevel}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: isHighRisk ? PdfColors.red800 : PdfColors.green800,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Score: ${result.score}',
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Medical Disclaimer
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'PAALALA: Ang ulat na ito ay pampasimulang screening lamang batay sa obserbasyon ng magulang at HINDI opisyal na medikal na diagnosis. Mangyaring isangguni ito sa isang Developmental Pediatrician para sa buong evaluation.',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              'Talaan ng mga Sagot',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              isAdhd
                  ? 'Ang markang (!) ay binibilang na sintomas ("Madalas" o "Palagi").'
                  : 'Ang markang (!) ay nagdagdag ng risk point sa kabuuang score.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),

            // Answers Table
            pw.TableHelper.fromTextArray(
              headers: ['#', 'Tanong / Item', 'Sagot', 'Marka'],
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: pw.BoxDecoration(color: headerColor),
              cellHeight: 24,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
              columnWidths: {
                0: const pw.FixedColumnWidth(30),
                1: const pw.FlexColumnWidth(),
                2: const pw.FixedColumnWidth(80),
                3: const pw.FixedColumnWidth(40),
              },
              data: rows
                  .map(
                    (row) => [
                      '${row.number}',
                      row.text,
                      row.answerLabel,
                      row.isAtRisk ? '!' : '',
                    ],
                  )
                  .toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }
}