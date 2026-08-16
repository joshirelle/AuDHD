import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/adhd_question.dart';
import '../widgets/screening_category.dart';
import '../widgets/screening_question_view.dart';
import 'adhd_result_screen.dart';

class ADHDScreeningScreen extends StatefulWidget {
  const ADHDScreeningScreen({super.key});

  @override
  State<ADHDScreeningScreen> createState() => _ADHDScreeningScreenState();
}

class _ADHDScreeningScreenState extends State<ADHDScreeningScreen> {
  final Map<String, int> _scores = {}; // 0 = Kailanman ... 3 = Palagi
  List<ADHDQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/json/vanderbilt_questions.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _questions = data.map((json) => ADHDQuestion.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  void _answerQuestion(int score) {
    final currentQ = _questions[_currentIndex];
    _scores[currentQ.id] = score;

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ADHDResultScreen(
            questions: _questions,
            userAnswers: _scores,
          ),
        ),
      );
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.logoGreen),
        ),
      );
    }

    final currentQ = _questions[_currentIndex];
    final selected = _scores[currentQ.id];

    return ScreeningQuestionView(
      currentIndex: _currentIndex,
      totalCount: _questions.length,
      tagLabel:
          'TANONG #${currentQ.number}  \u2022  ${currentQ.category.toUpperCase()}',
      category: ScreeningCategory.forVanderbilt(currentQ.category),
      questionText: currentQ.textTagalog,
      questionEnglish: currentQ.textEnglish,
      example: currentQ.exampleTagalog,
      onBack: _goBack,
      choices: [
        ScreeningChoice(
          label: 'Hindi Kailanman',
          color: AppColors.mintGreen,
          textColor: const Color(0xFF1E5631),
          isSelected: selected == 0,
          onPressed: () => _answerQuestion(0),
        ),
        ScreeningChoice(
          label: 'Minsan',
          color: AppColors.skyBlue,
          textColor: const Color(0xFF16537E),
          isSelected: selected == 1,
          onPressed: () => _answerQuestion(1),
        ),
        ScreeningChoice(
          label: 'Madalas',
          color: AppColors.butterYellow,
          textColor: const Color(0xFF7A5C00),
          isSelected: selected == 2,
          onPressed: () => _answerQuestion(2),
        ),
        ScreeningChoice(
          label: 'Palagi',
          color: AppColors.coralPeach,
          textColor: const Color(0xFF8A2B12),
          isSelected: selected == 3,
          onPressed: () => _answerQuestion(3),
        ),
      ],
    );
  }
}
