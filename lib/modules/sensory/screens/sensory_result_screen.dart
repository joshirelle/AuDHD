import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/sensory_labels.dart';
import '../../../core/services/pdf_export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sensory_profile_result.dart';
import '../../../data/services/hive_service.dart';

class SensoryResultScreen extends StatelessWidget {
  final SensoryProfileResult result;

  const SensoryResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    const maxScore = 15;
    final seekingPct = result.totalSeekingScore / maxScore;
    final avoidingPct = result.totalAvoidingScore / maxScore;
    final moodOnDay = HiveService.getMood(result.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buod ng Pandama'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.logoGreen),
            tooltip: 'I-export bilang PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Primary Result Header Card
          Card(
            color: AppColors.mintGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Pangunahing katangian:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    SensoryLabels.profile(result.primaryProfile),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.mintInk),
                  ),
                  if (moodOnDay != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.button),
                      ),
                      child: Text(
                        'Mood noong araw na iyon: $moodOnDay',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mintInk,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Visual Score Comparison (Seeking vs Avoiding)
          const Text('Kabuuang puntos (pinakamataas: 15)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          _buildScoreBar('Naghahanap ng pandama', result.totalSeekingScore, seekingPct, Colors.orange),
          const SizedBox(height: 10),
          _buildScoreBar('Umiiwas sa pandama', result.totalAvoidingScore, avoidingPct, Colors.purple),

          const SizedBox(height: 24),
          const Text('Bawat Uri ng Pandama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          ...result.domainBreakdown.entries.map((e) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(SensoryLabels.domain(e.key), style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDomainColor(e.value).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getDomainColor(e.value)),
                  ),
                  child: Text(
                    SensoryLabels.status(e.value),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _getDomainColor(e.value),
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    final child = HiveService.getChildProfile();
    final pdfData = await PdfExportService.generateSensoryReport(
      result,
      childName: child?.name,
      birthDate: child?.birthDate,
    );

    // Malayang teksto ang pangalan, kaya sinasala ang mga bawal sa filename.
    final safeName = (child?.name ?? 'Bata').replaceAll(RegExp(r'[^A-Za-z0-9]+'), '_');
    final d = result.timestamp;
    final fileDate = '${d.year}-${d.month}-${d.day}';

    await Printing.layoutPdf(
      onLayout: (format) => pdfData,
      name: 'Sensory_Profile_${safeName}_$fileDate.pdf',
    );
  }

  Widget _buildScoreBar(String label, int score, double pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('$score / 15', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 10,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Color _getDomainColor(String status) {
    if (status == 'Seeking') return Colors.orange.shade800;
    if (status == 'Avoiding') return Colors.purple.shade800;
    if (status == 'Mixed') return Colors.red.shade700;
    return Colors.green.shade700;
  }
}