import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sensory_profile_result.dart';

class SensoryResultScreen extends StatelessWidget {
  final SensoryProfileResult result;

  const SensoryResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    const maxScore = 15;
    final seekingPct = result.totalSeekingScore / maxScore;
    final avoidingPct = result.totalAvoidingScore / maxScore;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensory Profile Summary'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
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
                  const Text('Pangunahing Profile:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                    result.primaryProfile,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E5631)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Visual Score Comparison (Seeking vs Avoiding)
          const Text('Kabuuan ng Scores (Max: 15)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          _buildScoreBar('Sensory Seeking', result.totalSeekingScore, seekingPct, Colors.orange),
          const SizedBox(height: 10),
          _buildScoreBar('Sensory Avoiding / Sensitive', result.totalAvoidingScore, avoidingPct, Colors.purple),

          const SizedBox(height: 24),
          const Text('Per-Domain Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

          ...result.domainBreakdown.entries.map((e) {
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDomainColor(e.value).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _getDomainColor(e.value)),
                  ),
                  child: Text(
                    e.value,
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