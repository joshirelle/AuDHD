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
  int _currentIndex = 0;

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

  void _answerQuestion(int score) {
    final questions = SensoryConstants.questions;
    _answers[questions[_currentIndex].id] = score;

    if (_currentIndex < questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submitChecklist();
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = SensoryConstants.questions;
    final currentQ = questions[_currentIndex];
    final double progress = (_currentIndex + 1) / questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Header with Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentIndex > 0) {
                        setState(() => _currentIndex--);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF2A80B9)),
                        SizedBox(width: 4),
                        Text('Bumalik', style: TextStyle(color: Color(0xFF2A80B9), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          color: AppColors.mintGreen,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    '${_currentIndex + 1} / ${questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Center(
                child: Text(
                  '${currentQ.domain.toUpperCase()}  •  ${currentQ.type == SensoryType.seeking ? 'SEEKING' : 'AVOIDING'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Main Question Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.skyBlueLight, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 110,
                        child: Image.asset(
                          'assets/images/kiko_pointing.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Umaanguplo sa loob ng card kapag mahaba ang tanong.
                      Flexible(
                        child: SingleChildScrollView(
                          child: Text(
                            currentQ.textTagalog,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildChoiceButton(currentQ.id, 0, 'Kailanman', AppColors.mintGreen, const Color(0xFF1E5631)),
              const SizedBox(height: 10),
              _buildChoiceButton(currentQ.id, 1, 'Minsan', AppColors.skyBlue, const Color(0xFF16537E)),
              const SizedBox(height: 10),
              _buildChoiceButton(currentQ.id, 2, 'Madalas', AppColors.butterYellow, const Color(0xFF7A5C00)),
              const SizedBox(height: 10),
              _buildChoiceButton(currentQ.id, 3, 'Palagi', AppColors.coralPeach, const Color(0xFF8A2B12)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChoiceButton(String qId, int val, String label, Color color, Color textColor) {
    final bool isSelected = _answers[qId] == val;
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: isSelected ? textColor : Colors.transparent, width: 3),
          ),
        ),
        onPressed: () => _answerQuestion(val),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle_rounded, size: 18, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}