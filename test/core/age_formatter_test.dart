import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/utils/age_formatter.dart';

void main() {
  group('monthsBetween', () {
    test('counts whole months only', () {
      final birth = DateTime(2024, 1, 15);

      expect(AgeFormatter.monthsBetween(birth, DateTime(2024, 3, 15)), 2);
      expect(AgeFormatter.monthsBetween(birth, DateTime(2025, 1, 15)), 12);
    });

    test('does not count the current month until the birthday passes', () {
      final birth = DateTime(2024, 1, 20);

      expect(AgeFormatter.monthsBetween(birth, DateTime(2024, 3, 19)), 1);
      expect(AgeFormatter.monthsBetween(birth, DateTime(2024, 3, 20)), 2);
    });

    test('a future birth date gives a negative result', () {
      expect(
        AgeFormatter.monthsBetween(DateTime(2027, 1, 1), DateTime(2026, 1, 1)),
        lessThan(0),
      );
    });
  });

  group('formatMonths', () {
    test('shows years and months together', () {
      expect(AgeFormatter.formatMonths(25), '2 taon, 1 buwan (25 buwan)');
    });

    test('drops the months part on an exact year', () {
      expect(AgeFormatter.formatMonths(24), '2 taon (24 buwan)');
    });

    test('drops the years part below one year', () {
      expect(AgeFormatter.formatMonths(7), '7 buwan (7 buwan)');
    });

    test('newborns read as under one month', () {
      expect(AgeFormatter.formatMonths(0), 'Wala pang isang buwan');
    });

    test('a negative age is reported as invalid rather than rendered', () {
      expect(AgeFormatter.formatMonths(-3), AgeFormatter.invalidBirthDate);
    });
  });

  test('formatAge matches formatMonths over the same span', () {
    final birth = DateTime(2024, 1, 15);
    final asOf = DateTime(2026, 2, 16);

    expect(
      AgeFormatter.formatAge(birth, asOf),
      AgeFormatter.formatMonths(AgeFormatter.monthsBetween(birth, asOf)),
    );
  });
}
