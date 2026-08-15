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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.logoGreen)),
      );
    }

    bool isComplete = _scores.length == _questions.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ADHD Screening'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanong ${q.number} (${q.category})',
                          style: const TextStyle(fontSize: 12, color: AppColors.logoGreen, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(q.textTagalog, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildChoiceButton(q.id, 0, 'Kailanman', AppColors.mintGreen, const Color(0xFF1E5631)),
                        const SizedBox(height: 8),
                        _buildChoiceButton(q.id, 1, 'Minsan', AppColors.skyBlue, const Color(0xFF16537E)),
                        const SizedBox(height: 8),
                        _buildChoiceButton(q.id, 2, 'Madalas', AppColors.butterYellow, const Color(0xFF7A5C00)),
                        const SizedBox(height: 8),
                        _buildChoiceButton(q.id, 3, 'Palagi', AppColors.coralPeach, const Color(0xFF8A2B12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoGreen,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              onPressed: isComplete
                  ? () {
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
                  : null,
              child: const Text('Tapusin ang Assessment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String qId, int val, String label, Color color, Color textColor) {
    final bool isSelected = _scores[qId] == val;
    return SizedBox(
      height: 48,
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
        onPressed: () {
          setState(() {
            _scores[qId] = val;
          });
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSelected) ...[
              Icon(Icons.check_circle_rounded, size: 18, color: textColor),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}