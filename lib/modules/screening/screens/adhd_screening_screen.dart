import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/adhd_question.dart';
import 'adhd_result_screen.dart';

class ADHDScreeningScreen extends StatefulWidget {
  const ADHDScreeningScreen({super.key});

  @override
  State<ADHDScreeningScreen> createState() => _ADHDScreeningScreenState();
}

class _ADHDScreeningScreenState extends State<ADHDScreeningScreen> {
  final Map<String, int> _scores = {}; // 0 = Never, 1 = Sometimes, 2 = Often, 3 = Very Often
  List<ADHDQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final String response = await rootBundle.loadString('assets/json/vanderbilt_questions.json');
    final List<dynamic> data = json.decode(response);
    setState(() {
      _questions = data.map((json) => ADHDQuestion.fromJson(json)).toList();
      _isLoading = false;
    });
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
            Expanded(
              child: Text(
                'Paano ito sa bahay?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(example, style: const TextStyle(fontSize: 14, fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Nakuha ko!',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.logoGreen),
            ),
          ),
        ],
      ),
    );
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

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          'TANONG #${currentQ.number}  •  ${currentQ.category.toUpperCase()}',
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
                      Container(
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
                          children: [
                            SizedBox(
                              height: 110,
                              child: Image.asset(
                                'assets/images/kiko_pointing.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                            if (currentQ.exampleTagalog.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.skyBlue),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () => _showExampleDialog(currentQ.exampleTagalog),
                                icon: const Icon(Icons.help_outline_rounded, size: 18, color: Color(0xFF2A80B9)),
                                label: const Text(
                                  'Paano ito sa bahay?',
                                  style: TextStyle(color: Color(0xFF2A80B9), fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // Gaano kadalas ito nangyayari
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
    final bool isSelected = _scores[qId] == val;
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