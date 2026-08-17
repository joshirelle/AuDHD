import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../constants/sensory_constants.dart';
import '../../data/models/behavior_log.dart';
import '../../data/models/screening_answer_row.dart';
import '../../data/models/screening_result.dart';
import '../../data/models/sensory_profile_result.dart';
import 'pdf_report_theme.dart';

class PdfExportService {
  static const String _unknown = PdfReportTheme.unknown;

  static Future<Uint8List> generateScreeningReport(
    ScreeningResult result,
    List<ScreeningAnswerRow> rows, {
    String? childName,
    DateTime? birthDate,
  }) async {
    final pdf = pw.Document();
    final formattedDate = '${result.date.day}/${result.date.month}/${result.date.year}';
    final isAdhd = result.type == ScreeningResult.typeADHD;
    final screeningLabel = isAdhd ? 'Vanderbilt ADHD' : 'M-CHAT-R Autism';

    final nameText = (childName != null && childName.trim().isNotEmpty)
        ? childName.trim()
        : _unknown;
    final birthDateText = birthDate == null
        ? _unknown
        : '${birthDate.day}/${birthDate.month}/${birthDate.year}';
    final ageText = birthDate == null
        ? _unknown
        : _formatAge(birthDate, result.date);

    // Standard styling setup
    final isHighRisk = result.riskLevel.contains('HIGH');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _reportHeader('DEVELOPMENTAL SCREENING REPORT', formattedDate),
            _profileCard(
              nameText: nameText,
              birthDateText: birthDateText,
              ageLabel: 'Edad sa araw ng screening',
              ageText: ageText,
            ),
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

            _disclaimer(),
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
            PdfReportTheme.dataTable(
              headers: ['#', 'Tanong / Item', 'Sagot', 'Marka'],
              cellHeight: 24,
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
              columnWidths: {
                0: PdfReportTheme.narrowColumn,
                1: const pw.FlexColumnWidth(),
                // Kasya ang pinakamahabang sagot na "Hindi Kailanman".
                2: const pw.FixedColumnWidth(80),
                3: PdfReportTheme.narrowColumn,
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

  static Future<Uint8List> generateBehaviorReport(
    List<BehaviorLog> logs, {
    String? childName,
    DateTime? birthDate,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    final nameText = _nameOr(childName);
    final birthDateText = birthDate == null ? _unknown : _formatDate(birthDate);
    final ageText = birthDate == null ? _unknown : _formatAge(birthDate, now);

    final Map<String, int> triggerCounts = {};
    for (final log in logs) {
      for (final trigger in log.sensoryTriggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }
    final topTriggers = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sorted = [...logs]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _reportHeader('BEHAVIOR & TRIGGER LOG REPORT', _formatDate(now)),
            _profileCard(
              nameText: nameText,
              birthDateText: birthDateText,
              ageLabel: 'Edad sa araw ng ulat',
              ageText: ageText,
            ),
            pw.SizedBox(height: 16),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Kabuuang naitalang insidente: ${logs.length}',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'PINAKAMADALAS NA SENSORY TRIGGER',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (topTriggers.isEmpty)
                    pw.Text(
                      'Walang naitalang sensory tag.',
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    )
                  else
                    ...topTriggers
                        .take(5)
                        .map((e) => _profileRow(e.key, '${e.value} ulit')),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            _disclaimer(),
            pw.SizedBox(height: 20),

            pw.Text(
              'Talaan ng mga Insidente',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Nakaayos mula sa pinakabago. Ang tindi ay 1 (banayad) hanggang 5 (napakatindi).',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),

            PdfReportTheme.dataTable(
              headers: ['Petsa / Oras', 'A - B - C', 'Tindi', 'Min'],
              cellAlignments: {
                0: pw.Alignment.topLeft,
                1: pw.Alignment.topLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
              columnWidths: {
                0: PdfReportTheme.labelColumn,
                1: const pw.FlexColumnWidth(),
                2: PdfReportTheme.narrowColumn,
                3: PdfReportTheme.narrowColumn,
              },
              data: sorted.map((log) {
                final abc = StringBuffer()
                  ..writeln('A: ${log.antecedent}')
                  ..writeln('B: ${log.behavior}')
                  ..write('C: ${log.consequence}');
                if (log.sensoryTriggers.isNotEmpty) {
                  abc.write('\nTags: ${log.sensoryTriggers.join(', ')}');
                }
                return [
                  '${_formatDate(log.timestamp)}\n${_formatTime(log.timestamp)}',
                  abc.toString(),
                  '${log.intensity}/5',
                  '${log.durationMinutes}',
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateSensoryReport(
    SensoryProfileResult result, {
    String? childName,
    DateTime? birthDate,
  }) async {
    final pdf = pw.Document();

    final nameText = _nameOr(childName);
    final birthDateText = birthDate == null ? _unknown : _formatDate(birthDate);
    final ageText =
        birthDate == null ? _unknown : _formatAge(birthDate, result.timestamp);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _reportHeader('SENSORY PROFILE REPORT', _formatDate(result.timestamp)),
            _profileCard(
              nameText: nameText,
              birthDateText: birthDateText,
              ageLabel: 'Edad sa araw ng assessment',
              ageText: ageText,
            ),
            pw.SizedBox(height: 16),

            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey50,
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'PANGUNAHING PROFILE',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    result.primaryProfile,
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 12),
                  _profileRow('Sensory Seeking', '${result.totalSeekingScore} / 15'),
                  _profileRow(
                    'Sensory Avoiding / Sensitive',
                    '${result.totalAvoidingScore} / 15',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            _disclaimer(),
            pw.SizedBox(height: 20),

            pw.Text(
              'Breakdown kada Domain',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            PdfReportTheme.dataTable(
              headers: ['Sensory Domain', 'Resulta'],
              cellHeight: 24,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.center,
              },
              columnWidths: {
                0: const pw.FlexColumnWidth(),
                1: const pw.FixedColumnWidth(110),
              },
              data: result.domainBreakdown.entries
                  .map((e) => [e.key, e.value])
                  .toList(),
            ),
            pw.SizedBox(height: 20),

            pw.Text(
              'Talaan ng mga Sagot',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              '0 = Hindi Kailanman, 1 = Minsan, 2 = Madalas, 3 = Palagi.',
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),
            PdfReportTheme.dataTable(
              headers: ['Domain', 'Tanong', 'Uri', 'Sagot'],
              cellAlignments: {
                0: pw.Alignment.topLeft,
                1: pw.Alignment.topLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
              },
              columnWidths: {
                0: PdfReportTheme.labelColumn,
                1: const pw.FlexColumnWidth(),
                2: PdfReportTheme.mediumColumn,
                3: PdfReportTheme.narrowColumn,
              },
              data: SensoryConstants.questions
                  .map(
                    (q) => [
                      q.domain,
                      q.textTagalog,
                      q.type == SensoryType.seeking ? 'Seeking' : 'Avoiding',
                      '${result.answers[q.id] ?? 0}',
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

  static String _nameOr(String? childName) => PdfReportTheme.nameOr(childName);

  static String _formatDate(DateTime date) => PdfReportTheme.formatDate(date);

  static String _formatTime(DateTime date) => PdfReportTheme.formatTime(date);

  static pw.Widget _reportHeader(String title, String dateText) =>
      PdfReportTheme.reportHeader(title, dateText);

  static pw.Widget _profileCard({
    required String nameText,
    required String birthDateText,
    required String ageLabel,
    required String ageText,
  }) => PdfReportTheme.profileCard(
    nameText: nameText,
    birthDateText: birthDateText,
    ageLabel: ageLabel,
    ageText: ageText,
  );

  static pw.Widget _disclaimer() => PdfReportTheme.disclaimer();

  static pw.Widget _profileRow(String label, String value) =>
      PdfReportTheme.profileRow(label, value);

  static String _formatAge(DateTime birthDate, DateTime asOf) =>
      PdfReportTheme.formatAge(birthDate, asOf);
}