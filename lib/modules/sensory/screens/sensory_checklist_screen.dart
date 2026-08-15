import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/sensory_constants.dart';
import '../../../core/services/sensory_calculator_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sensory_profile_result.dart';
import '../../../data/services/hive_service.dart';
import 'sensory_result_screen.dart';

class SensoryChecklistScreen extends StatefulWidget {
  const SensoryChecklistScreen({super.key});

  @override
  State<SensoryChecklistScreen> createState() => _SensoryChecklistScreenState();
}

class _SensoryChecklistScreenState extends State<SensoryChecklistScreen> {
  final Map<String, int> _answers = {};

  void _submitChecklist() async {
    if (_answers.length < SensoryConstants.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mangyaring sagutan ang lahat ng tanong bago magpatuloy.'),
          backgroundColor: Color(0xFFD9A000),
        ),
      );
      return;
    }

    final calculated = SensoryCalculatorService.calculateProfile(_answers);

    final result = SensoryProfileResult(
      id: const Uuid().v4(),
      timestamp: DateTime.now(),
      answers: _answers,
      totalSeekingScore: calculated['totalSeekingScore'],
      totalAvoidingScore: calculated['totalAvoidingScore'],
      primaryProfile: calculated['primaryProfile'],
      domainBreakdown: Map<String, String>.from(calculated['domainBreakdown']),
    );

    // Save sa Hive (Siguraduhing naka-open ang box)
    final box = HiveService.getSensoryBox();
    await box.put(result.id, result);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SensoryResultScreen(result: result),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensory Profile Checklist'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Obserbasyon sa Sensory Processing',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pumili mula 0 (Hindi kelanman) hanggang 3 (Palagi) batay sa pang-araw-araw na kilos ng bata.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          ...SensoryConstants.questions.map((q) {
            final currentScore = _answers[q.id];

            return Card(
              margin: const EdgeInsets.only(bottom: 12.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.mintGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            q.domain,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E5631)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      q.textTagalog,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),

                    // Choice Chips 0-3
                    Wrap(
                      spacing: 6,
                      children: [0, 1, 2, 3].map((score) {
                        final isSelected = currentScore == score;
                        return ChoiceChip(
                          label: Text(
                            score == 0 ? '0 - Hindi' : score == 1 ? '1 - Minsan' : score == 2 ? '2 - Madalas' : '3 - Palagi',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected ? Colors.white : AppColors.textDark,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: AppColors.logoGreen,
                          onSelected: (_) {
                            setState(() {
                              _answers[q.id] = score;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitChecklist,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoGreen,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'TINGNAN ANG RESULTA',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}