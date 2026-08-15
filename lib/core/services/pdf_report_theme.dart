import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Magkatulad na header, profile card, at disclaimer sa lahat ng PDF na ulat.
class PdfReportTheme {
  static const String unknown = 'Hindi nakatala';
  static const PdfColor headerColor = PdfColors.teal800;

  static String nameOr(String? childName) =>
      (childName != null && childName.trim().isNotEmpty)
      ? childName.trim()
      : unknown;

  static String formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';

  static String formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour < 12 ? 'AM' : 'PM'}';
  }

  /// Katulad ng lohika sa MChatAgeCheckScreen para hindi magkaiba ang edad na ipinapakita.
  static String formatAge(DateTime birthDate, DateTime asOf) {
    int months =
        (asOf.year - birthDate.year) * 12 + asOf.month - birthDate.month;
    if (asOf.day < birthDate.day) months--;
    if (months < 0) return 'Hindi wasto ang kaarawan';
    return formatMonths(months);
  }

  static String formatMonths(int months) {
    if (months < 0) return unknown;

    final years = months ~/ 12;
    final remainder = months % 12;
    final parts = <String>[];
    if (years > 0) parts.add('$years taon');
    if (remainder > 0) parts.add('$remainder buwan');
    if (parts.isEmpty) return 'Wala pang isang buwan (0 buwan)';
    return '${parts.join(', ')} ($months buwan)';
  }

  static pw.Widget reportHeader(
    String title,
    String dateText, {
    pw.ImageProvider? logo,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null) ...[
              pw.SizedBox(height: 46, width: 46, child: pw.Image(logo)),
              pw.SizedBox(width: 12),
            ],
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: headerColor,
                    ),
                  ),
                  pw.Text(
                    'Tala ng Obserbasyon ng Magulang',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.Text('Petsa: $dateText', style: const pw.TextStyle(fontSize: 11)),
          ],
        ),
        pw.SizedBox(height: 16),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 16),
      ],
    );
  }

  static pw.Widget profileCard({
    required String nameText,
    required String birthDateText,
    required String ageLabel,
    required String ageText,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(14),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'DETALYE NG BATA',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          profileRow('Pangalan', nameText),
          profileRow('Kaarawan', birthDateText),
          profileRow(ageLabel, ageText),
        ],
      ),
    );
  }

  static pw.Widget disclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        'PAALALA: Ang ulat na ito ay pampasimulang screening lamang batay sa obserbasyon ng magulang at HINDI opisyal na medikal na diagnosis. Mangyaring isangguni ito sa isang Developmental Pediatrician para sa buong evaluation.',
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      ),
    );
  }

  static pw.Widget profileRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(
              '$label:',
              style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey800),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget sectionTitle(String title, {String? subtitle}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
        if (subtitle != null) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            subtitle,
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ],
    );
  }
}
