import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../constants/sensory_constants.dart';
import '../i18n/language_controller.dart';
import '../../data/models/behavior_log.dart';
import '../../data/models/screening_answer_row.dart';
import '../../data/models/screening_result.dart';
import '../../data/models/sensory_profile_result.dart';
import 'pdf_report_theme.dart';

class PdfExportService {
  // Getter, hindi const: nakadepende sa wikang pinili ng magulang.
  static String get _unknown => PdfReportTheme.unknown;

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
            _reportHeader(
              tr(
                'ULAT NG DEVELOPMENTAL SCREENING',
                'DEVELOPMENTAL SCREENING REPORT',
              ),
              formattedDate,
            ),
            _profileCard(
              nameText: nameText,
              birthDateText: birthDateText,
              ageLabel: tr(
                'Edad sa araw ng screening',
                'Age on the day of screening',
              ),
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
                        tr(
                          'Uri ng Screening: $screeningLabel',
                          'Screening type: $screeningLabel',
                        ),
                        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        tr(
                          'Kategorya: ${result.riskLevel}',
                          'Category: ${result.riskLevel}',
                        ),
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: isHighRisk ? PdfColors.red800 : PdfColors.green800,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(
                    tr('Puntos: ${result.score}', 'Score: ${result.score}'),
                    style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            _disclaimer(),
            pw.SizedBox(height: 20),

            pw.Text(
              tr('Talaan ng mga Sagot', 'Table of Answers'),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              isAdhd
                  ? tr(
                      'Ang markang (!) ay binibilang na sintomas ("Madalas" o "Palagi").',
                      'The (!) mark is counted as a symptom ("Often" or "Always").',
                    )
                  : tr(
                      'Ang markang (!) ay nagdagdag ng risk point sa kabuuang score.',
                      'The (!) mark added a risk point to the total score.',
                    ),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),

            // Answers Table
            PdfReportTheme.dataTable(
              headers: [
                '#',
                tr('Tanong / Item', 'Question / Item'),
                tr('Sagot', 'Answer'),
                tr('Marka', 'Mark'),
              ],
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
            _reportHeader(
              tr(
                'ULAT NG TALA NG UGALI AT TRIGGER',
                'BEHAVIOR & TRIGGER LOG REPORT',
              ),
              _formatDate(now),
            ),
            _profileCard(
              nameText: nameText,
              birthDateText: birthDateText,
              ageLabel: tr(
                'Edad sa araw ng ulat',
                'Age on the day of the report',
              ),
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
                    tr(
                      'Kabuuang naitalang insidente: ${logs.length}',
                      'Total recorded incidents: ${logs.length}',
                    ),
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    tr(
                      'PINAKAMADALAS NA SENSORY TRIGGER',
                      'MOST FREQUENT SENSORY TRIGGERS',
                    ),
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  if (topTriggers.isEmpty)
                    pw.Text(
                      tr(
                        'Walang naitalang sensory tag.',
                        'No sensory tags recorded.',
                      ),
                      style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                    )
                  else
                    ...topTriggers
                        .take(5)
                        .map(
                          (e) => _profileRow(
                            e.key,
                            tr('${e.value} ulit', '${e.value} times'),
                          ),
                        ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            _disclaimer(),
            pw.SizedBox(height: 20),

            pw.Text(
              tr('Talaan ng mga Insidente', 'Table of Incidents'),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              tr(
                'Nakaayos mula sa pinakabago. Ang tindi ay 1 (banayad) hanggang 5 (napakatindi).',
                'Sorted newest first. The intensity level runs from 1 (mild) to 5 (very intense).',
              ),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),

            PdfReportTheme.dataTable(
              headers: [
                tr('Petsa / Oras', 'Date / Time'),
                'A - B - C',
                tr('Tindi', 'Level'),
                'Min',
              ],
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
            _reportHeader(
              tr('ULAT NG PROFILE NG PANDAMA', 'SENSORY PROFILE REPORT'),
              _formatDate(result.timestamp),
            ),
            _profileCard(
              nameText: nameText,
              birthDateText: birthDateText,
              ageLabel: tr(
                'Edad sa araw ng assessment',
                'Age on the day of the assessment',
              ),
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
                    tr('PANGUNAHING PROFILE', 'PRIMARY PROFILE'),
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
                  _profileRow(
                    tr('Naghahanap ng pandama', 'Sensory Seeking'),
                    '${result.totalSeekingScore} / 15',
                  ),
                  _profileRow(
                    tr(
                      'Umiiwas / sensitibo sa pandama',
                      'Sensory Avoiding / Sensitive',
                    ),
                    '${result.totalAvoidingScore} / 15',
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            _disclaimer(),
            pw.SizedBox(height: 20),

            pw.Text(
              tr('Bawat Uri ng Pandama', 'Breakdown per Domain'),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            PdfReportTheme.dataTable(
              headers: [
                tr('Uri ng Pandama', 'Sensory Domain'),
                tr('Resulta', 'Result'),
              ],
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
              tr('Talaan ng mga Sagot', 'Table of Answers'),
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              tr(
                '0 = Hindi Kailanman, 1 = Minsan, 2 = Madalas, 3 = Palagi.',
                '0 = Never, 1 = Sometimes, 2 = Often, 3 = Always.',
              ),
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 10),
            PdfReportTheme.dataTable(
              headers: [
                tr('Pandama', 'Domain'),
                tr('Tanong', 'Question'),
                tr('Uri', 'Type'),
                tr('Sagot', 'Answer'),
              ],
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
                      q.type == SensoryType.seeking
                          ? tr('Naghahanap', 'Seeking')
                          : tr('Umiiwas', 'Avoiding'),
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