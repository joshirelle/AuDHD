import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sensory_profile_result.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import 'sensory_checklist_screen.dart';
import 'sensory_result_screen.dart';

class SensoryHistoryScreen extends StatelessWidget {
  const SensoryHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasaysayan ng Sensory Profile'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
      ),
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startChecklist(context),
        backgroundColor: AppColors.logoGreen,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Bagong Assessment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<Box<SensoryProfileResult>>(
        valueListenable: HiveService.getSensoryBox().listenable(),
        builder: (context, box, _) {
          final results = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (results.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Wala pang naitalang sensory assessment.\n'
                  'I-click ang "Bagong Assessment" para magsimula.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
                _buildResultCard(context, results[index], results.length - index),
          );
        },
      ),
    );
  }

  void _startChecklist(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SensoryChecklistScreen()),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    SensoryProfileResult result,
    int number,
  ) {
    return KikoCard(
      backgroundColor: const Color(0xFFF0F7F7),
      borderColor: AppColors.logoGreen.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SensoryResultScreen(result: result),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.logoGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.logoGreen,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assessment #$number',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.primaryProfile,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        fontFamily: 'Nunito',
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(result.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textDark,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildScorePill(
                  'Seeking',
                  result.totalSeekingScore,
                  AppColors.butterYellow,
                  const Color(0xFF7A5C00),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildScorePill(
                  'Avoiding',
                  result.totalAvoidingScore,
                  AppColors.skyBlueLight,
                  const Color(0xFF16537E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScorePill(
    String label,
    int score,
    Color background,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Text(
        '$label: $score / 15',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFamily: 'Nunito',
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Enero',
      'Pebrero',
      'Marso',
      'Abril',
      'Mayo',
      'Hunyo',
      'Hulyo',
      'Agosto',
      'Setyembre',
      'Oktubre',
      'Nobyembre',
      'Disyembre',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
