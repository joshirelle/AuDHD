import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/mchat_scoring.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/mchat_question.dart';
import '../../../data/models/screening_result.dart';
import '../../../data/services/hive_service.dart';
import '../../../widgets/screening_attribution.dart';
import '../../../widgets/screening_disclaimer.dart';

class MChatResultScreen extends StatefulWidget {
  final List<MChatQuestion> questions;
  final Map<String, bool> userAnswers;

  const MChatResultScreen({
    super.key,
    required this.questions,
    required this.userAnswers,
  });

  @override
  State<MChatResultScreen> createState() => _MChatResultScreenState();
}

class _MChatResultScreenState extends State<MChatResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveToDatabase();
  }

  int _calculateScore() =>
      MChatScoring.calculateScore(widget.questions, widget.userAnswers);

  Future<void> _saveToDatabase() async {
    final int score = _calculateScore();
    final String risk = MChatScoring.riskLevelFor(score);

    final result = ScreeningResult(
      id: const Uuid().v4(),
      date: DateTime.now(),
      score: score,
      riskLevel: risk,
      type: ScreeningResult.typeMChat,
      answers: widget.userAnswers,
    );

    await HiveService.saveScreeningResult(result);
  }

  @override
  Widget build(BuildContext context) {
    final int totalScore = _calculateScore();
    
    String riskTitle = "LOW RISK";
    Color riskColor = AppColors.success;
    String message = "Mababa ang panganib ng Autism base sa pamantayan ng M-CHAT-R. Ipagpatuloy ang pag-subaybay sa milestones ni Kiko.";

    if (totalScore >= 3 && totalScore <= 7) {
      riskTitle = "MEDIUM RISK";
      riskColor = AppColors.warning;
      message = "Katamtaman ang panganib. Inirerekomenda ang pagkonsulta sa isang Developmental Pediatrician.";
    } else if (totalScore >= 8) {
      riskTitle = "HIGH RISK";
      riskColor = AppColors.danger;
      message = "Mataas ang panganib. Maiging magpa-appointment agad sa Developmental Pediatrician.";
    }

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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: riskColor, width: 2),
                ),
                child: Column(
                  children: [
                    Text(
                      'RESULTA NG PAGSUSURI',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      riskTitle,
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: riskColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Score: $totalScore / 20 Risk Points',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark),
                    ),
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
                child: const Text('Bumalik sa Home', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              const ScreeningCopyright(text: ScreeningAttribution.mchat),
            ],
          ),
        ),
      ),
    );
  }
}