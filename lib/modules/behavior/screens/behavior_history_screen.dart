import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. SENSORY TRIGGER ANALYTICS SUMMARY
              _buildSensorySummaryCard(logs),
              const SizedBox(height: 20),

              const Text(
                'Mga Naitalang Insidente',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // 2. INCIDENT CARDS LIST
              ...logs.map((log) => _buildBehaviorCard(context, log)),
            ],
          );
        },
      ),
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Top Sensory Triggers',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.logoGreen),
                ),
                Text(
                  'Kabuuan: ${logs.length} insidente',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${entry.value} ulit (${(percentage * 100).toStringAsFixed(0)}%)',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage,
                          minHeight: 8,
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date, Severity Badge, at Duration
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: severityColor),
                  ),
                  child: Text(
                    'Intensity: ${log.intensity}/5 (${log.durationMinutes} min)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ABC Summary
            _buildAbcRow('A (Antecedent):', log.antecedent),
            const SizedBox(height: 4),
            _buildAbcRow('B (Behavior):', log.behavior),
            const SizedBox(height: 4),
            _buildAbcRow('C (Consequence):', log.consequence),

            if (log.sensoryTriggers.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: log.sensoryTriggers.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlueLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '# $tag',
                      style: const TextStyle(fontSize: 10, color: Color(0xFF16537E)),
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
        style: const TextStyle(fontSize: 12, color: AppColors.textDark),
        children: [
          TextSpan(text: '$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: value),
        ],
      ),
    );
  }

  // Kapareho ng risk colours na ginagamit sa screening result at history.
  Color _getSeverityColor(int intensity) {
    if (intensity <= 2) return const Color(0xFF2D7A4D);
    if (intensity <= 3) return const Color(0xFFD9A000);
    return const Color(0xFFD9383A);
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}