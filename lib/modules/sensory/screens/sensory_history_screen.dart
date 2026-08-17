import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/sensory_profile_result.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/kiko_card.dart';
import '../../../core/constants/sensory_labels.dart';
import '../../../widgets/how_to_card.dart';
import 'sensory_checklist_screen.dart';
import 'sensory_result_screen.dart';

class SensoryHistoryScreen extends StatelessWidget {
  const SensoryHistoryScreen({super.key});

  static const _howTo = HowToCard(
    steps: [
      'Pindutin ang "Bagong Checklist" para simulan ang mga tanong.',
      'Sagutin ang bawat tanong batay sa tunay mong nakikita sa bahay, hindi '
          'sa inaasahan mo.',
      'Basahin ang resulta para malaman kung anong pandama ang hinahanap o '
          'iniiwasan ng bata.',
      'Pindutin nang matagal ang isang checklist kung gusto mong burahin.',
    ],
    footnote:
        'Ulitin ito tuwing ilang buwan. Ang pagbabago ng resulta ang '
        'magsasabi kung ano ang umeepekto sa kanya.',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasaysayan ng Pandama'),
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
          'Bagong Checklist',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: ValueListenableBuilder<Box<SensoryProfileResult>>(
        valueListenable: HiveService.getSensoryBox().listenable(),
        builder: (context, box, _) {
          final results = box.values.toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (results.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              children: const [
                _howTo,
                SizedBox(height: 24),
                Text(
                  'Wala pang naitalang checklist ng pandama.\n'
                  'I-click ang "Bagong Checklist" para magsimula.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            itemCount: results.length + 1,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) => index == 0
                ? _howTo
                : _buildResultCard(
                    context,
                    results[index - 1],
                    results.length - index + 1,
                  ),
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

  Future<void> _confirmDelete(
    BuildContext context,
    SensoryProfileResult result,
  ) async {
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text(
          'Burahin ang checklist?',
          style: TextStyle(fontSize: 17, fontFamily: 'Nunito'),
        ),
        content: const Text(
          'Hindi na ito mababawi, at mawawala rin ito sa ulat para sa doktor.',
          style: TextStyle(fontSize: 14, fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Hindi',
              style: TextStyle(fontFamily: 'Nunito', color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Burahin',
              style: TextStyle(fontFamily: 'Nunito', color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      await HiveService.deleteSensoryResult(result.id);
    }
  }

  Widget _buildResultCard(
    BuildContext context,
    SensoryProfileResult result,
    int number,
  ) {
    return KikoCard(
      backgroundColor: AppColors.tintTeal,
      borderColor: AppColors.logoGreen.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(16),
      onLongPress: () => _confirmDelete(context, result),
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
                      'Checklist #$number',
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
                      SensoryLabels.profile(result.primaryProfile),
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
                      DateFormatter.longDate(result.timestamp),
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
                  'Naghahanap',
                  result.totalSeekingScore,
                  AppColors.butterYellow,
                  AppColors.butterInk,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildScorePill(
                  'Umiiwas',
                  result.totalAvoidingScore,
                  AppColors.skyBlueLight,
                  AppColors.skyInk,
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
}
