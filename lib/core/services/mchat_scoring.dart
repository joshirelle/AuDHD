import '../../data/models/mchat_question.dart';

/// Iisang batayan ng M-CHAT-R scoring para hindi magkaiba ang result screen,
/// ang answer table, at ang PDF.
class MChatScoring {
  static const String riskLow = 'LOW RISK';
  static const String riskMedium = 'MEDIUM RISK';
  static const String riskHigh = 'HIGH RISK';

  static const int mediumRiskThreshold = 3;
  static const int highRiskThreshold = 8;

  /// Sa items 2, 5 at 12 ang "OO" ang at-risk, kaya hindi sapat ang oo/hindi.
  static bool isAtRisk(MChatQuestion question, Object? answer) =>
      answer == question.atRiskAnswer;

  static int calculateScore(
    List<MChatQuestion> questions,
    Map<String, dynamic> answers,
  ) {
    int score = 0;
    for (final question in questions) {
      if (isAtRisk(question, answers[question.id])) score++;
    }
    return score;
  }

  static String riskLevelFor(int score) {
    if (score >= highRiskThreshold) return riskHigh;
    if (score >= mediumRiskThreshold) return riskMedium;
    return riskLow;
  }
}
