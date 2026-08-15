import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/services/mchat_scoring.dart';
import 'package:kiko_app/data/models/mchat_question.dart';

MChatQuestion _question(String id, {required bool atRiskAnswer}) {
  return MChatQuestion(
    id: id,
    questionNumber: int.parse(id.split('_').last),
    textTagalog: 'Tanong $id',
    textEnglish: 'Question $id',
    example: 'Halimbawa',
    atRiskAnswer: atRiskAnswer,
  );
}

void main() {
  group('isAtRisk', () {
    test('normal item counts when the parent answers HINDI', () {
      final question = _question('mchat_1', atRiskAnswer: false);

      expect(MChatScoring.isAtRisk(question, false), isTrue);
      expect(MChatScoring.isAtRisk(question, true), isFalse);
    });

    test('reverse-scored item counts when the parent answers OO', () {
      // Items 2, 5 at 12 ang baligtad sa M-CHAT-R.
      final question = _question('mchat_2', atRiskAnswer: true);

      expect(MChatScoring.isAtRisk(question, true), isTrue);
      expect(MChatScoring.isAtRisk(question, false), isFalse);
    });

    test('unanswered item does not count', () {
      final question = _question('mchat_1', atRiskAnswer: false);

      expect(MChatScoring.isAtRisk(question, null), isFalse);
    });
  });

  group('calculateScore', () {
    final questions = [
      _question('mchat_1', atRiskAnswer: false),
      _question('mchat_2', atRiskAnswer: true),
      _question('mchat_3', atRiskAnswer: false),
    ];

    test('counts only at-risk answers', () {
      final score = MChatScoring.calculateScore(questions, {
        'mchat_1': false, // at risk
        'mchat_2': true, // at risk (baligtad)
        'mchat_3': false, // at risk
      });

      expect(score, 3);
    });

    test('answering OO everywhere does not score every item', () {
      final score = MChatScoring.calculateScore(questions, {
        'mchat_1': true,
        'mchat_2': true, // ito lang ang at risk
        'mchat_3': true,
      });

      expect(score, 1);
    });

    test('missing answers are skipped rather than treated as at risk', () {
      expect(MChatScoring.calculateScore(questions, const {}), 0);
    });
  });

  group('riskLevelFor', () {
    test('below three points is low risk', () {
      expect(MChatScoring.riskLevelFor(0), MChatScoring.riskLow);
      expect(MChatScoring.riskLevelFor(2), MChatScoring.riskLow);
    });

    test('three to seven points is medium risk', () {
      expect(MChatScoring.riskLevelFor(3), MChatScoring.riskMedium);
      expect(MChatScoring.riskLevelFor(7), MChatScoring.riskMedium);
    });

    test('eight points and above is high risk', () {
      expect(MChatScoring.riskLevelFor(8), MChatScoring.riskHigh);
      expect(MChatScoring.riskLevelFor(20), MChatScoring.riskHigh);
    });
  });
}
