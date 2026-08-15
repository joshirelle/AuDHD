import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/mchat_question.dart';
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
    final String response = await rootBundle.loadString('assets/json/mchat_questions.json');
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
      setState(() {
        _currentIndex++;
      });
    } else {
      // Kapag natapos na ang 20 questions, pumunta sa Result Screen
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

  void _showExampleDialog(String example) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: AppColors.logoGreen),
            SizedBox(width: 8),
            Text('Paano ito sa bahay?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(example, style: const TextStyle(fontSize: 14, fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Nakuha ko!', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.logoGreen)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.logoGreen)),
      );
    }

    final currentQ = _questions[_currentIndex];
    final double progress = (_currentIndex + 1) / _questions.length;

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
                    '${_currentIndex + 1} / ${_questions.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Question Title Tag
              Center(
                child: Text(
                  'TANONG #${currentQ.questionNumber}',
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
                    children: [
                      // Kiko Illustration Banner — kada tanong may sariling larawan.
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/${currentQ.id}.png',
                            fit: BoxFit.contain,
                            // Bumabalik sa default kapag wala pang larawan ang tanong.
                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              'assets/images/kiko_pointing.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Question Text
                      Text(
                        currentQ.textTagalog,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Help button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.skyBlue),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => _showExampleDialog(currentQ.example),
                        icon: const Icon(Icons.help_outline_rounded, size: 18, color: Color(0xFF2A80B9)),
                        label: const Text(
                          'Paano ito sa bahay?',
                          style: TextStyle(color: Color(0xFF2A80B9), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons ("OO" and "HINDI")
              _buildActionButton(
                label: 'OO, ginagawa niya ito',
                color: AppColors.mintGreen,
                textColor: const Color(0xFF1E5631),
                onPressed: () => _answerQuestion(true),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                label: 'HINDI pa niya ginagawa',
                color: AppColors.coralPeach,
                textColor: const Color(0xFF8A2B12),
                onPressed: () => _answerQuestion(false),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}