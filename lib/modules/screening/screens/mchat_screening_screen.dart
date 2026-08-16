import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/mchat_question.dart';
import '../widgets/screening_category.dart';
import '../widgets/screening_question_view.dart';
import 'mchat_result_screen.dart';

class MChatScreeningScreen extends StatefulWidget {
  const MChatScreeningScreen({super.key});

  @override
  State<MChatScreeningScreen> createState() => _MChatScreeningScreenState();
}

class _MChatScreeningScreenState extends State<MChatScreeningScreen> {
  List<MChatQuestion> _questions = [];
  int _currentIndex = 0;
  final Map<String, bool> _userAnswers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/json/mchat_questions.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _questions = data.map((json) => MChatQuestion.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  void _answerQuestion(bool answer) {
    final currentQ = _questions[_currentIndex];
    _userAnswers[currentQ.id] = answer;

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MChatResultScreen(
            questions: _questions,
            userAnswers: _userAnswers,
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
    final selected = _userAnswers[currentQ.id];

    return ScreeningQuestionView(
      currentIndex: _currentIndex,
      totalCount: _questions.length,
      tagLabel: 'TANONG #${currentQ.questionNumber}',
      category: ScreeningCategory.forMChat(currentQ.category),
      questionText: currentQ.textTagalog,
      questionEnglish: currentQ.textEnglish,
      example: currentQ.example,
      onBack: _goBack,
      choices: [
        // Yes/No ang M-CHAT-R; hindi lahat ng tanong ay tungkol sa ginagawa ng bata.
        ScreeningChoice(
          label: 'OO',
          color: AppColors.mintGreen,
          textColor: const Color(0xFF1E5631),
          isSelected: selected == true,
          onPressed: () => _answerQuestion(true),
        ),
        ScreeningChoice(
          label: 'HINDI',
          color: AppColors.coralPeach,
          textColor: const Color(0xFF8A2B12),
          isSelected: selected == false,
          onPressed: () => _answerQuestion(false),
        ),
      ],
    );
  }
}
