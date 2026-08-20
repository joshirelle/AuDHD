import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../core/i18n/language_controller.dart';
import '../../../core/models/mood_type.dart';
import '../../../core/services/pdf_report_theme.dart';
import '../../../data/models/behavior_log.dart';
import '../../../data/models/sensory_profile_result.dart';
import '../../../data/services/hive_service.dart';

class DoctorPdfService {
  static const int rangeLast30Days = 30;
  static const int rangeLast90Days = 90;

  static const String _logoAsset = 'assets/images/kiko_waving.png';

  static Future<Uint8List> generateDoctorReport({
    required String childName,
    required int childAgeMonths,
    int rangeDays = rangeLast30Days,
  }) async {
    final now = DateTime.now();
    final cutoff = now.subtract(Duration(days: rangeDays));

    final logs =
        HiveService.getAllLogs()
            .where((log) => log.timestamp.isAfter(cutoff))
            .toList()
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final sensoryResults = HiveService.getAllSensoryResults();
    final SensoryProfileResult? sensory = sensoryResults.isEmpty
        ? null
        : sensoryResults.first;

    final birthDate = HiveService.getChildProfile()?.birthDate;
    final moods = HiveService.getMoodsInRange(cutoff, now);
    final logo = await _loadLogo();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          PdfReportTheme.reportHeader(
            tr(
              'ULAT NG PAG-UNLAD PARA SA DOKTOR',
              'PROGRESS REPORT FOR DOCTOR',
            ),
            PdfReportTheme.formatDate(now),
            logo: logo,
          ),
          PdfReportTheme.profileCard(
            nameText: PdfReportTheme.nameOr(childName),
            birthDateText: birthDate == null
                ? PdfReportTheme.unknown
                : PdfReportTheme.formatDate(birthDate),
            ageLabel: tr(
              'Edad sa araw ng ulat',
              'Age on the day of the report',
            ),
            ageText: PdfReportTheme.formatMonths(childAgeMonths),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            tr(
              'Saklaw ng ulat: huling $rangeDays araw '
                  '(${PdfReportTheme.formatDate(cutoff)} - ${PdfReportTheme.formatDate(now)})',
              'Report period: last $rangeDays days '
                  '(${PdfReportTheme.formatDate(cutoff)} - ${PdfReportTheme.formatDate(now)})',
            ),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),

          _moodSummary(moods),
          pw.SizedBox(height: 16),

          PdfReportTheme.disclaimer(),
          pw.SizedBox(height: 20),

          ..._behaviorSection(logs, rangeDays, moods),
          pw.SizedBox(height: 20),

          ..._sensorySection(sensory),
          pw.SizedBox(height: 20),

          ..._routineSection(rangeDays, cutoff, now),
        ],
      ),
    );

    return pdf.save();
  }

  static Future<pw.ImageProvider?> _loadLogo() async {
    try {
      final data = await rootBundle.load(_logoAsset);
      return pw.MemoryImage(data.buffer.asUint8List());
    } catch (_) {
      // Mas mabuti ang ulat na walang logo kaysa sa ulat na hindi mabuo.
      return null;
    }
  }

  /// Kinukulayan ayon sa tono, hindi kada mood, para hindi ito mapag-iwanan
  /// tuwing may naidadagdag na bagong damdamin.
  static PdfColor _moodColorForLabel(String label) {
    switch (MoodType.fromLabel(label)?.tone) {
      case MoodTone.positive:
        return PdfColors.green100;
      case MoodTone.neutral:
        return PdfColors.blue100;
      case MoodTone.negative:
        return PdfColors.orange100;
      case null:
        return PdfColors.grey100;
    }
  }

  static pw.Widget _moodSummary(Map<String, String> moods) {
    if (moods.isEmpty) {
      return _emptyNote(
        tr(
          'Araw-araw na mood: wala pang naitala sa saklaw na ito.',
          'Daily mood: nothing recorded yet for this period.',
        ),
      );
    }

    final counts = <String, int>{};
    for (final mood in moods.values) {
      final label = MoodType.labelFor(mood);
      counts[label] = (counts[label] ?? 0) + 1;
    }
    final ranked = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = moods.length;

    return pw.Container(
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
            tr('ARAW-ARAW NA MOOD', 'DAILY MOOD'),
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            tr(
              'Naitala ng magulang sa $total araw. Hindi ito klinikal na sukatan.',
              'Recorded by the parent on $total days. This is not a clinical measure.',
            ),
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              for (final entry in ranked)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(right: 8),
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: pw.BoxDecoration(
                      color: _moodColorForLabel(entry.key),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Text(
                      tr(
                        '${entry.key}: ${entry.value} araw '
                            '(${(entry.value / total * 100).round()}%)',
                        '${entry.key}: ${entry.value} days '
                            '(${(entry.value / total * 100).round()}%)',
                      ),
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _behaviorSection(
    List<BehaviorLog> logs,
    int days,
    Map<String, String> moods,
  ) {
    final title = tr(
      '1. Tala ng Ugali (A-B-C) - huling $days araw',
      '1. Behavior Log (A-B-C) - last $days days',
    );

    if (logs.isEmpty) {
      return [
        PdfReportTheme.sectionTitle(title),
        pw.SizedBox(height: 8),
        _emptyNote(
          tr(
            'Walang naitalang insidente sa saklaw na ito.',
            'No incidents recorded for this period.',
          ),
        ),
      ];
    }

    final Map<String, int> triggerCounts = {};
    for (final log in logs) {
      for (final trigger in log.sensoryTriggers) {
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
      }
    }
    final topTriggers = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final totalIntensity = logs.fold<int>(0, (sum, log) => sum + log.intensity);
    final averageIntensity = (totalIntensity / logs.length).toStringAsFixed(1);

    return [
      PdfReportTheme.sectionTitle(
        title,
        subtitle: tr(
          'Ang tindi ay 1 (banayad) hanggang 5 (napakatindi).',
          'The intensity level runs from 1 (mild) to 5 (very intense).',
        ),
      ),
      pw.SizedBox(height: 10),
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
            PdfReportTheme.profileRow(
              tr('Bilang ng insidente', 'Number of incidents'),
              '${logs.length}',
            ),
            PdfReportTheme.profileRow(
              tr('Karaniwang tindi', 'Average intensity'),
              '$averageIntensity / 5',
            ),
            pw.SizedBox(height: 8),
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
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              )
            else
              ...topTriggers
                  .take(5)
                  .map(
                    (e) => PdfReportTheme.profileRow(
                      e.key,
                      tr('${e.value} ulit', '${e.value} times'),
                    ),
                  ),
          ],
        ),
      ),
      pw.SizedBox(height: 12),
      PdfReportTheme.dataTable(
        headers: [
          tr('Petsa / Oras', 'Date / Time'),
          'A - B - C',
          'Mood',
          tr('Tindi', 'Level'),
          'Min',
        ],
        cellDecoration: (column, data, row) => pw.BoxDecoration(
          color: column == 2
              ? _moodColorForLabel(data.toString())
              : PdfColors.white,
        ),
        cellAlignments: {
          0: pw.Alignment.topLeft,
          1: pw.Alignment.topLeft,
          2: pw.Alignment.center,
          3: pw.Alignment.center,
          4: pw.Alignment.center,
        },
        columnWidths: {
          0: PdfReportTheme.labelColumn,
          1: const pw.FlexColumnWidth(),
          2: PdfReportTheme.mediumColumn,
          3: PdfReportTheme.narrowColumn,
          4: PdfReportTheme.narrowColumn,
        },
        data: logs.map((log) {
          final abc = StringBuffer()
            ..writeln('A: ${log.antecedent}')
            ..writeln('B: ${log.behavior}')
            ..write('C: ${log.consequence}');
          if (log.sensoryTriggers.isNotEmpty) {
            abc.write('\nTags: ${log.sensoryTriggers.join(', ')}');
          }
          return [
            '${PdfReportTheme.formatDate(log.timestamp)}\n'
                '${PdfReportTheme.formatTime(log.timestamp)}',
            abc.toString(),
            moods[HiveService.dateKey(log.timestamp)] == null
                ? '-'
                : MoodType.labelFor(moods[HiveService.dateKey(log.timestamp)]!),
            '${log.intensity}/5',
            '${log.durationMinutes}',
          ];
        }).toList(),
      ),
    ];
  }

  static List<pw.Widget> _sensorySection(SensoryProfileResult? result) {
    if (result == null) {
      return [
        PdfReportTheme.sectionTitle(
          tr('2. Profile ng Pandama', '2. Sensory Profile'),
        ),
        pw.SizedBox(height: 8),
        _emptyNote(
          tr(
            'Wala pang naitalang sensory profile checklist.',
            'No sensory profile checklist recorded yet.',
          ),
        ),
      ];
    }

    return [
      PdfReportTheme.sectionTitle(
        tr('2. Profile ng Pandama', '2. Sensory Profile'),
        subtitle: tr(
          'Pinakahuling assessment noong '
              '${PdfReportTheme.formatDate(result.timestamp)}.',
          'Latest assessment on '
              '${PdfReportTheme.formatDate(result.timestamp)}.',
        ),
      ),
      pw.SizedBox(height: 10),
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
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            PdfReportTheme.profileRow(
              tr('Naghahanap ng pandama', 'Sensory Seeking'),
              '${result.totalSeekingScore} / 15',
            ),
            PdfReportTheme.profileRow(
              tr(
                'Umiiwas / sensitibo sa pandama',
                'Sensory Avoiding / Sensitive',
              ),
              '${result.totalAvoidingScore} / 15',
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 12),
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
    ];
  }

  /// Ang mababang bahagdan dito ay madalas hindi pagkukulang ng magulang kundi
  /// palatandaan ng hirap sa isang partikular na gawain — mahirap itong
  /// maikuwento sa maikling konsulta pero kitang-kita sa talahanayan.
  static List<pw.Widget> _routineSection(
    int rangeDays,
    DateTime cutoff,
    DateTime now,
  ) {
    final tasks = HiveService.getScheduleTasks();
    final counts = HiveService.scheduleDoneCountsInRange(cutoff, now);

    if (tasks.isEmpty || counts.isEmpty) {
      return [
        PdfReportTheme.sectionTitle(tr('3. Rutina sa Bahay', '3. Home Routine')),
        pw.SizedBox(height: 8),
        _emptyNote(
          tr(
            'Wala pang naitalang rutina sa saklaw na ito.',
            'No routine recorded yet for this period.',
          ),
        ),
      ];
    }

    final activeDays = HiveService.scheduleActiveDaysInRange(cutoff, now);
    final possible = tasks.length * rangeDays;
    // Nananatili sa box ang tala ng binurang gawain; kung isasama ito, lalampas
    // ang bahagdan sa 100% dahil kasalukuyang gawain lang ang `possible`.
    final done = tasks.fold(0, (sum, task) => sum + (counts[task.id] ?? 0));
    final percent = possible == 0 ? 0 : (done * 100 / possible).round();

    final ranked =
        tasks.map((task) => MapEntry(task, counts[task.id] ?? 0)).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return [
      PdfReportTheme.sectionTitle(tr('3. Rutina sa Bahay', '3. Home Routine')),
      pw.SizedBox(height: 8),
      pw.Text(
        tr(
          'Nasunod na rutina: $percent% ($done sa $possible na posible). '
              'May naitalang gawain sa $activeDays sa $rangeDays araw.',
          'Routine followed: $percent% ($done of $possible possible). '
              'Tasks were recorded on $activeDays of $rangeDays days.',
        ),
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
      ),
      pw.SizedBox(height: 12),
      PdfReportTheme.dataTable(
        headers: [
          tr('Gawain', 'Task'),
          tr('Oras', 'Time'),
          tr('Nagawa', 'Done'),
          tr('Bahagi', 'Rate'),
        ],
        cellHeight: 22,
        cellAlignments: {
          0: pw.Alignment.centerLeft,
          1: pw.Alignment.center,
          2: pw.Alignment.center,
          3: pw.Alignment.center,
        },
        columnWidths: {
          0: const pw.FlexColumnWidth(),
          1: PdfReportTheme.mediumColumn,
          2: PdfReportTheme.mediumColumn,
          3: PdfReportTheme.narrowColumn,
        },
        data: ranked
            .map(
              (entry) => [
                entry.key.titleTagalog,
                entry.key.timeOfDay.label,
                '${entry.value} / $rangeDays',
                '${(entry.value * 100 / rangeDays).round()}%',
              ],
            )
            .toList(),
      ),
    ];
  }

  static pw.Widget _emptyNote(String message) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Text(
        message,
        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
      ),
    );
  }
}
