import 'dart:convert';
import 'package:flutter/services.dart';
import '../../data/models/adhd_question.dart';

/// Iisang batayan ng Vanderbilt scoring para hindi magkaiba ang app at ang PDF.
class VanderbiltScoring {
  static const String assetPath = 'assets/json/vanderbilt_questions.json';

  static const String categoryInattention = 'Inattention';
  static const String categoryHyperactivity = 'Hyperactivity';

  /// Sa Vanderbilt, ang "Madalas" (2) o "Palagi" (3) lang ang binibilang na sintomas.
  static const int symptomThreshold = 2;
  static const int riskThreshold = 6;

  static Future<List<ADHDQuestion>> loadQuestions() async {
    final List<dynamic> data = json.decode(await rootBundle.loadString(assetPath));
    return data
        .map((item) => ADHDQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static int totalIn(List<ADHDQuestion> questions, String category) =>
      questions.where((q) => q.category == category).length;

  static int symptomCount(
    List<ADHDQuestion> questions,
    Map<String, dynamic> answers,
    String category,
  ) {
    int count = 0;
    for (final q in questions.where((item) => item.category == category)) {
      final value = answers[q.id];
      if (value is int && value >= symptomThreshold) count++;
    }
    return count;
  }

  static bool isHighRisk(int inattention, int hyperactivity) =>
      inattention >= riskThreshold || hyperactivity >= riskThreshold;
}
