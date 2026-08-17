import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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
            'PROGRESS REPORT FOR DOCTOR',
            PdfReportTheme.formatDate(now),
            logo: logo,
          ),
          PdfReportTheme.profileCard(
            nameText: PdfReportTheme.nameOr(childName),
            birthDateText: birthDate == null
                ? PdfReportTheme.unknown
                : PdfReportTheme.formatDate(birthDate),
            ageLabel: 'Edad sa araw ng ulat',
            ageText: PdfReportTheme.formatMonths(childAgeMonths),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Saklaw ng ulat: huling $rangeDays araw '
            '(${PdfReportTheme.formatDate(cutoff)} - ${PdfReportTheme.formatDate(now)})',
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
        'Araw-araw na mood: wala pang naitala sa saklaw na ito.',
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
            'ARAW-ARAW NA MOOD',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Naitala ng magulang sa $total araw. Hindi ito klinikal na sukatan.',
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
                      '${entry.key}: ${entry.value} araw '
                      '(${(entry.value / total * 100).round()}%)',
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
    final title = '1. Tala ng Ugali (A-B-C) - huling $days araw';

    if (logs.isEmpty) {
      return [
        PdfReportTheme.sectionTitle(title),
        pw.SizedBox(height: 8),
        _emptyNote('Walang naitalang insidente sa saklaw na ito.'),
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
        subtitle: 'Ang tindi ay 1 (banayad) hanggang 5 (napakatindi).',
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
              'Bilang ng insidente',
              '${logs.length}',
            ),
            PdfReportTheme.profileRow(
              'Karaniwang tindi',
              '$averageIntensity / 5',
            ),
            pw.SizedBox(height: 8),
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
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey700,
                ),
              )
            else
              ...topTriggers
                  .take(5)
                  .map((e) => PdfReportTheme.profileRow(e.key, '${e.value} ulit')),
          ],
        ),
      ),
      pw.SizedBox(height: 12),
      PdfReportTheme.dataTable(
        headers: ['Petsa / Oras', 'A - B - C', 'Mood', 'Tindi', 'Min'],
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
        PdfReportTheme.sectionTitle('2. Sensory Profile'),
        pw.SizedBox(height: 8),
        _emptyNote('Wala pang naitalang sensory profile checklist.'),
      ];
    }

    return [
      PdfReportTheme.sectionTitle(
        '2. Sensory Profile',
        subtitle:
            'Pinakahuling assessment noong '
            '${PdfReportTheme.formatDate(result.timestamp)}.',
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
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
            PdfReportTheme.profileRow(
              'Sensory Seeking',
              '${result.totalSeekingScore} / 15',
            ),
            PdfReportTheme.profileRow(
              'Sensory Avoiding / Sensitive',
              '${result.totalAvoidingScore} / 15',
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 12),
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
