import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/services/vanderbilt_scoring.dart';
import 'package:kiko_app/data/models/adhd_question.dart';

ADHDQuestion _question(int number, String category) {
  return ADHDQuestion(
    id: 'adhd_$number',
    number: number,
    textTagalog: 'Tanong $number',
    textEnglish: 'Question $number',
    exampleTagalog: 'Halimbawa',
    category: category,
  );
}

/// Siyam na Inattention at siyam na Hyperactivity, gaya ng tunay na asset.
final _questions = [
  for (var i = 1; i <= 9; i++)
    _question(i, VanderbiltScoring.categoryInattention),
  for (var i = 10; i <= 18; i++)
    _question(i, VanderbiltScoring.categoryHyperactivity),
];

Map<String, dynamic> _answersFor(Iterable<int> numbers, int value) {
  return {for (final n in numbers) 'adhd_$n': value};
}

void main() {
  group('totalIn', () {
    test('each subscale holds nine items', () {
      expect(
        VanderbiltScoring.totalIn(
          _questions,
          VanderbiltScoring.categoryInattention,
        ),
        9,
      );
      expect(
        VanderbiltScoring.totalIn(
          _questions,
          VanderbiltScoring.categoryHyperactivity,
        ),
        9,
      );
    });
  });

  group('symptomCount', () {
    test('Kailanman and Minsan are not symptoms', () {
      final answers = {
        ..._answersFor([1, 2, 3, 4], 0),
        ..._answersFor([5, 6, 7, 8, 9], 1),
      };

      expect(
        VanderbiltScoring.symptomCount(
          _questions,
          answers,
          VanderbiltScoring.categoryInattention,
        ),
        0,
      );
    });

    test('Madalas and Palagi both count', () {
      final answers = {
        ..._answersFor([1, 2, 3], 2), // Madalas
        ..._answersFor([4, 5], 3), // Palagi
        ..._answersFor([6, 7, 8, 9], 1), // Minsan
      };

      expect(
        VanderbiltScoring.symptomCount(
          _questions,
          answers,
          VanderbiltScoring.categoryInattention,
        ),
        5,
      );
    });

    test('the other subscale is not mixed in', () {
      final answers = _answersFor([10, 11, 12, 13, 14, 15], 3);

      expect(
        VanderbiltScoring.symptomCount(
          _questions,
          answers,
          VanderbiltScoring.categoryInattention,
        ),
        0,
      );
      expect(
        VanderbiltScoring.symptomCount(
          _questions,
          answers,
          VanderbiltScoring.categoryHyperactivity,
        ),
        6,
      );
    });

    test('unanswered and non-numeric values are ignored', () {
      // Ang Hive ay nagbabalik ng dynamic, kaya posible ang hindi int.
      final answers = <String, dynamic>{'adhd_1': null, 'adhd_2': 'Palagi'};

      expect(
        VanderbiltScoring.symptomCount(
          _questions,
          answers,
          VanderbiltScoring.categoryInattention,
        ),
        0,
      );
    });
  });

  group('isHighRisk', () {
    test('five symptoms in both subscales stays low risk', () {
      expect(VanderbiltScoring.isHighRisk(5, 5), isFalse);
    });

    test('six symptoms in either subscale is enough', () {
      expect(VanderbiltScoring.isHighRisk(6, 0), isTrue);
      expect(VanderbiltScoring.isHighRisk(0, 6), isTrue);
    });

    test('no symptoms is low risk', () {
      expect(VanderbiltScoring.isHighRisk(0, 0), isFalse);
    });
  });
}
