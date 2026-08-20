import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/behavior_constants.dart';
import '../../../core/i18n/language_controller.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/behavior_log.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/how_to_card.dart';
import 'add_behavior_log_screen.dart';

class BehaviorHistoryScreen extends StatelessWidget {
  const BehaviorHistoryScreen({super.key});

  static HowToCard get _howTo => HowToCard(
    steps: [
      tr(
        'Kapag may nangyaring hindi inaasahan, itala agad habang sariwa pa sa '
            'isip.',
        'When something unexpected happens, log it right away while it is '
            'still fresh.',
      ),
      tr(
        'Sagutin ang tatlo: ang nangyari bago (A), ang mismong ginawa ng bata '
            '(B), at ang nangyari pagkatapos (C).',
        'Answer three things: what happened before (A), what the child did '
            '(B), and what happened after (C).',
      ),
      tr(
        'Piliin mula sa listahan kung ano ang posibleng nag-udyok nito.',
        'Pick from the list what may have set this off.',
      ),
      tr(
        'Pindutin nang matagal ang isang tala kung mali ito at gusto mong burahin.',
        'Press and hold a log if it is wrong and you want to delete it.',
      ),
    ],
    footnote: tr(
      'Hindi mo kailangang magtala araw-araw. Sa loob ng ilang linggo, '
          'lilitaw ang paulit-ulit na sanhi, at iyon ang pinakamahalagang '
          'maipakita sa doktor.',
      'You do not need to log every day. Over a few weeks the repeating '
          'causes will show up, and those are the most important thing to '
          'show the doctor.',
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Talaan ng Ugali', 'Behavior Log')),
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.logoGreen,
            ),
            tooltip: tr('I-export bilang PDF', 'Export as PDF'),
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddBehaviorLogScreen(),
            ),
          );
        },
        backgroundColor: AppColors.logoGreen,
        icon: const Icon(Icons.add_rounded, color: AppColors.surface),
        label: Text(
          tr('Magdagdag ng Tala', 'Add a Log'),
          style: const TextStyle(
            color: AppColors.surface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ValueListenableBuilder<Box<BehaviorLog>>(
        valueListenable: HiveService.getBehaviorBox().listenable(),
        builder: (context, box, _) {
          final logs = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (logs.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
              children: [
                _howTo,
                const SizedBox(height: 24),
                Text(
                  tr(
                    'Wala ka pang naitatalang ugali.\n'
                        'I-click ang "Magdagdag ng Tala" para magsimula.',
                    'You have no logs yet.\n'
                        'Tap "Add a Log" to start.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
            children: [
              _howTo,
              const SizedBox(height: 20),

              // 1. SENSORY TRIGGER ANALYTICS SUMMARY
              _buildSensorySummaryCard(logs),
              const SizedBox(height: 24),

              Text(
                tr('Mga Naitalang Insidente', 'Logged Incidents'),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 14),

              // 2. INCIDENT CARDS LIST
              ...logs.map(
                (log) => GestureDetector(
                  onLongPress: () => _confirmDelete(context, log),
                  child: _buildBehaviorCard(context, log),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _exportPdf(BuildContext context) async {
    final logs = HiveService.getAllLogs();
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Wala pang maitatalang insidente sa ulat.',
              'There are no incidents yet to put in the report.',
            ),
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final child = HiveService.getChildProfile();
    final pdfData = await PdfExportService.generateBehaviorReport(
      logs,
      childName: child?.name,
      birthDate: child?.birthDate,
    );

    // Malayang teksto ang pangalan, kaya sinasala ang mga bawal sa filename.
    final safeName = (child?.name ?? 'Bata').replaceAll(
      RegExp(r'[^A-Za-z0-9]+'),
      '_',
    );
    final now = DateTime.now();
    final fileDate = '${now.year}-${now.month}-${now.day}';

    await Printing.layoutPdf(
      onLayout: (format) => pdfData,
      name: 'Behavior_Log_${safeName}_$fileDate.pdf',
    );
  }

  // Visual Summary Widget para sa Sensory Triggers
  Widget _buildSensorySummaryCard(List<BehaviorLog> logs) {
    // Kuhanin ang bilang ng bawat sensory trigger
    final Map<String, int> triggerCounts = {};
    int totalTriggersLogged = 0;

    for (var log in logs) {
      for (var trigger in log.sensoryTriggers) {
        // Iisang susi ang magkatulad na tala kahit iba ang wikang ginamit.
        final key = BehaviorConstants.canonical(trigger);
        triggerCounts[key] = (triggerCounts[key] ?? 0) + 1;
        totalTriggersLogged++;
      }
    }

    // I-sort mula pinakamadalas hanggang sa pinaka-bihira
    final sortedEntries = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.skyBlueLight, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tr('Pinakamadalas na sanhi', 'Most common causes'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.logoGreen,
                  ),
                ),
                Text(
                  tr('${logs.length} insidente', '${logs.length} incidents'),
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedEntries.isEmpty)
              Text(
                tr(
                  'Walang sensory tags na naitala.',
                  'No sensory tags logged.',
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              )
            else
              ...sortedEntries.take(4).map((entry) {
                final percentage = totalTriggersLogged > 0
                    ? entry.value / totalTriggersLogged
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            BehaviorConstants.localize(entry.key),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            tr(
                              '${entry.value} ulit (${(percentage * 100).toStringAsFixed(0)}%)',
                              '${entry.value} times (${(percentage * 100).toStringAsFixed(0)}%)',
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 10,
                          backgroundColor: AppColors.divider,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.logoGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // Individual Card para sa bawat Incident Log
  Widget _buildBehaviorCard(BuildContext context, BehaviorLog log) {
    final formattedDate =
        '${log.timestamp.day}/${log.timestamp.month}/${log.timestamp.year} • ${_formatTime(log.timestamp)}';
    final severityColor = _getSeverityColor(log.intensity);

    return Container(
      margin: const EdgeInsets.only(bottom: 14.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date, Severity Badge, at Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(
                    '${log.intensity}/5  •  ${log.durationMinutes} min',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ABC Summary
            _buildAbcRow(
              tr('Bago mangyari:', 'Before:'),
              BehaviorConstants.localize(log.antecedent),
            ),
            const SizedBox(height: 8),
            _buildAbcRow(
              tr('Ang ginawa:', 'Behavior:'),
              BehaviorConstants.localize(log.behavior),
            ),
            const SizedBox(height: 8),
            _buildAbcRow(
              tr('Pagkatapos:', 'After:'),
              BehaviorConstants.localize(log.consequence),
            ),

            if (log.sensoryTriggers.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: log.sensoryTriggers.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlueLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '# ${BehaviorConstants.localize(tag)}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.skyInk,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, BehaviorLog log) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: Text(
          tr('Burahin ang tala?', 'Delete this log?'),
          style: const TextStyle(fontSize: 17, fontFamily: 'Nunito'),
        ),
        content: Text(
          tr(
            'Hindi na ito mababawi, at mawawala rin ito sa ulat para sa doktor.',
            'This cannot be undone, and it will also be gone from the doctor\'s report.',
          ),
          style: const TextStyle(fontSize: 14, fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              tr('Hindi', 'No'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              tr('Burahin', 'Delete'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.danger,
              ),
            ),
          ),
        ],
      ),
    );

    if (isConfirmed == true) await HiveService.deleteLog(log.id);
  }

  Widget _buildAbcRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textDark,
          height: 1.35,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // Kapareho ng risk colours na ginagamit sa screening result at history.
  Color _getSeverityColor(int intensity) {
    if (intensity <= 2) return AppColors.success;
    if (intensity <= 3) return AppColors.warning;
    return AppColors.danger;
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
