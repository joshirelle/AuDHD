import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:printing/printing.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/behavior_log.dart';
import '../../../data/services/hive_service.dart';
import 'add_behavior_log_screen.dart';

class BehaviorHistoryScreen extends StatelessWidget {
  const BehaviorHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Talaan ng Kilos at Triggers'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.logoGreen),
            tooltip: 'Export as PDF',
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBehaviorLogScreen()),
          );
        },
        backgroundColor: AppColors.logoGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Mag-tala ng Log',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<Box<BehaviorLog>>(
        valueListenable: HiveService.getBehaviorBox().listenable(),
        builder: (context, box, _) {
          final logs = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (logs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Wala pang naitalang behavior log.\nI-click ang "+" button para magdagdag.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            children: [
              // 1. SENSORY TRIGGER ANALYTICS SUMMARY
              _buildSensorySummaryCard(logs),
              const SizedBox(height: 24),

              const Text(
                'Mga Naitalang Insidente',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
              const SizedBox(height: 14),

              // 2. INCIDENT CARDS LIST
              ...logs.map((log) => _buildBehaviorCard(context, log)),
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
        const SnackBar(
          content: Text('Wala pang maitatalang insidente sa ulat.'),
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
    final safeName = (child?.name ?? 'Bata').replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
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
        triggerCounts[trigger] = (triggerCounts[trigger] ?? 0) + 1;
        totalTriggersLogged++;
      }
    }

    // I-sort mula pinakamadalas hanggang sa pinaka-bihira
    final sortedEntries = triggerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
                const Text(
                  'Top Sensory Triggers',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.logoGreen),
                ),
                Text(
                  '${logs.length} insidente',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (sortedEntries.isEmpty)
              const Text(
                'Walang sensory tags na naitala.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
                            entry.key,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${entry.value} ulit (${(percentage * 100).toStringAsFixed(0)}%)',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.logoGreen),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: severityColor.withValues(alpha: 0.35), width: 2),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            _buildAbcRow('A (Antecedent):', log.antecedent),
            const SizedBox(height: 8),
            _buildAbcRow('B (Behavior):', log.behavior),
            const SizedBox(height: 8),
            _buildAbcRow('C (Consequence):', log.consequence),

            if (log.sensoryTriggers.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: log.sensoryTriggers.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlueLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '# $tag',
                      style: const TextStyle(fontSize: 10, color: AppColors.skyInk),
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

  Widget _buildAbcRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.35),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
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
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}