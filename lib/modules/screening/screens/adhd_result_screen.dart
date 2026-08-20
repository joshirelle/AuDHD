import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/vanderbilt_scoring.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/adhd_question.dart';
import '../../../data/models/screening_result.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/screening_attribution.dart';
import '../../../widgets/screening_disclaimer.dart';

class ADHDResultScreen extends StatefulWidget {
  final List<ADHDQuestion> questions;
  final Map<String, int> userAnswers;

  const ADHDResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<ADHDResultScreen> createState() => _ADHDResultScreenState();
}

class _ADHDResultScreenState extends State<ADHDResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveToDatabase();
  }

  int _totalIn(String category) =>
      VanderbiltScoring.totalIn(widget.questions, category);

  int _symptomCount(String category) => VanderbiltScoring.symptomCount(
    widget.questions,
    widget.userAnswers,
    category,
  );

  bool _isHighRisk(int inattention, int hyperactivity) =>
      VanderbiltScoring.isHighRisk(inattention, hyperactivity);

  Future<void> _saveToDatabase() async {
    final int inattention = _symptomCount(VanderbiltScoring.categoryInattention);
    final int hyperactivity = _symptomCount(
      VanderbiltScoring.categoryHyperactivity,
    );

    final result = ScreeningResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      score: inattention + hyperactivity,
      riskLevel: _isHighRisk(inattention, hyperactivity) ? 'HIGH RISK' : 'LOW RISK',
      type: ScreeningResult.typeADHD,
      answers: widget.userAnswers,
    );

    await HiveService.saveScreeningResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final int inattention = _symptomCount('Inattention');
    final int hyperactivity = _symptomCount('Hyperactivity');
    final bool highRisk = _isHighRisk(inattention, hyperactivity);

    final String riskTitle = highRisk ? 'HIGH RISK' : 'LOW RISK';
    final Color riskColor = highRisk ? AppColors.danger : AppColors.success;
    final String message = highRisk
        ? 'Mataas ang posibilidad ng ADHD symptoms. Inirerekomenda ang pagpapasuri sa isang Specialist.'
        : 'Mababa ang posibilidad ng ADHD base sa pamantayan ng Vanderbilt. Ipagpatuloy ang pag-subaybay kay Kiko.';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: riskColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'RESULTA NG PAGSUSURI',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      riskTitle,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: riskColor),
                    ),
                    const SizedBox(height: 16),
                    _buildBreakdownRow('Inattention', inattention, _totalIn('Inattention')),
                    const SizedBox(height: 8),
                    _buildBreakdownRow('Hyperactivity', hyperactivity, _totalIn('Hyperactivity')),
                    const Divider(height: 32),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 16, color: AppColors.logoGreen),
                        SizedBox(width: 4),
                        Text('Na-save na sa local storage', style: TextStyle(fontSize: 12, color: AppColors.logoGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const ScreeningDisclaimer(),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                child: const Text('Bumalik sa Home', style: TextStyle(color: AppColors.surface, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              const ScreeningCopyright(text: ScreeningAttribution.vanderbilt),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, int count, int total) {
    final bool met = count >= 6;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textDark)),
        Text(
          '$count / $total na sintomas',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: met ? AppColors.danger : AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
