import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../i18n/language_controller.dart';
import '../utils/age_formatter.dart';

/// Magkatulad na header, profile card, at disclaimer sa lahat ng PDF na ulat.
class PdfReportTheme {
  // Getter, hindi const: nakadepende sa wikang pinili ng magulang.
  static String get unknown => tr('Hindi nakatala', 'Not recorded');
  static const PdfColor headerColor = PdfColors.teal800;
  static const double tableFontSize = 9;

  /// Sapat para sa bilang at maikling sagot gaya ng "Tindi", "Min", o "Sagot".
  static const pw.TableColumnWidth narrowColumn = pw.FixedColumnWidth(48);

  /// Sapat para sa isang salita gaya ng label ng mood o uri.
  static const pw.TableColumnWidth mediumColumn = pw.FixedColumnWidth(62);

  /// Sapat para sa petsa at oras na magkasunod na linya.
  static const pw.TableColumnWidth labelColumn = pw.FixedColumnWidth(76);

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
  static String formatAge(DateTime birthDate, DateTime asOf) =>
      AgeFormatter.formatAge(birthDate, asOf);

  static String formatMonths(int months) => AgeFormatter.formatMonths(months);

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
                    tr(
                      'Tala ng Obserbasyon ng Magulang',
                      'Record of Parent Observations',
                    ),
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.Text(
              tr('Petsa: $dateText', 'Date: $dateText'),
              style: const pw.TextStyle(fontSize: 11),
            ),
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
            tr('DETALYE NG BATA', 'CHILD DETAILS'),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 8),
          profileRow(tr('Pangalan', 'Name'), nameText),
          profileRow(tr('Kaarawan', 'Date of birth'), birthDateText),
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
        tr(
          'PAALALA: Ang ulat na ito ay tala lamang ng obserbasyon ng magulang sa bahay at HINDI opisyal na medikal na diagnosis. Mangyaring isangguni ito sa isang Developmental Pediatrician para sa buong evaluation.',
          "NOTE: This report is only a record of the parent's observations at home and is NOT an official medical diagnosis. Please refer it to a Developmental Pediatrician for a full evaluation.",
        ),
        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
      ),
    );
  }

  /// Iisang ayos ng talahanayan sa lahat ng PDF. Pareho ang laki ng titik sa
  /// header at sa laman, kaya hindi na napuputol ang maiikling pamagat.
  static pw.Widget dataTable({
    required List<String> headers,
    required List<List<dynamic>> data,
    Map<int, pw.Alignment>? cellAlignments,
    Map<int, pw.TableColumnWidth>? columnWidths,
    pw.OnCellDecoration? cellDecoration,
    double cellHeight = 0,
  }) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(
        fontSize: tableFontSize,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: headerColor),
      cellStyle: const pw.TextStyle(fontSize: tableFontSize),
      cellHeight: cellHeight,
      cellAlignments: cellAlignments,
      columnWidths: columnWidths,
      cellDecoration: cellDecoration,
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
