import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/sensory_constants.dart';
import '../../../core/services/sensory_calculator_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/sensory_profile_result.dart';
import '../../../data/services/hive_service.dart';
import '../../screening/widgets/screening_category.dart';
import '../../screening/widgets/screening_question_view.dart';
import 'sensory_result_screen.dart';

class SensoryChecklistScreen extends StatefulWidget {
  const SensoryChecklistScreen({super.key});

  @override
  State<SensoryChecklistScreen> createState() => _SensoryChecklistScreenState();
}

class _SensoryChecklistScreenState extends State<SensoryChecklistScreen> {
  final Map<String, int> _answers = {};
  int _currentIndex = 0;

  Future<void> _submitChecklist() async {
    if (_answers.length < SensoryConstants.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mangyaring sagutan ang lahat ng tanong bago magpatuloy.'),
          backgroundColor: AppColors.warning,
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

    await HiveService.addSensoryResult(result);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SensoryResultScreen(result: result),
      ),
    );
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

  void _goBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = SensoryConstants.questions;
    final currentQ = questions[_currentIndex];
    final selected = _answers[currentQ.id];

    return ScreeningQuestionView(
      currentIndex: _currentIndex,
      totalCount: questions.length,
      tagLabel: 'TANONG #${_currentIndex + 1}',
      category: ScreeningCategory.forSensory(currentQ.domain),
      questionText: currentQ.textTagalog,
      questionEnglish: '',
      example: '',
      onBack: _goBack,
      choices: [
        ScreeningChoice(
          label: 'Hindi Kailanman',
          color: AppColors.mintGreen,
          textColor: AppColors.mintInk,
          isSelected: selected == 0,
          onPressed: () => _answerQuestion(0),
        ),
        ScreeningChoice(
          label: 'Minsan',
          color: AppColors.skyBlue,
          textColor: AppColors.skyInk,
          isSelected: selected == 1,
          onPressed: () => _answerQuestion(1),
        ),
        ScreeningChoice(
          label: 'Madalas',
          color: AppColors.butterYellow,
          textColor: AppColors.butterInk,
          isSelected: selected == 2,
          onPressed: () => _answerQuestion(2),
        ),
        ScreeningChoice(
          label: 'Palagi',
          color: AppColors.coralPeach,
          textColor: AppColors.coralInk,
          isSelected: selected == 3,
          onPressed: () => _answerQuestion(3),
        ),
      ],
    );
  }
}
