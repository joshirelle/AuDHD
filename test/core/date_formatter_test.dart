import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/utils/date_formatter.dart';

void main() {
  group('timeGreeting', () {
    test('umaga starts at 5 and ends before 12', () {
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 5)),
        'Magandang umaga',
      );
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 11, 59)),
        'Magandang umaga',
      );
    });

    test('hapon starts at 12 and ends before 18', () {
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 12)),
        'Magandang hapon',
      );
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 17, 59)),
        'Magandang hapon',
      );
    });

    test('gabi covers the evening and the small hours', () {
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 18)),
        'Magandang gabi',
      );
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 23, 59)),
        'Magandang gabi',
      );
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 0)),
        'Magandang gabi',
      );
      expect(
        DateFormatter.timeGreeting(DateTime(2026, 8, 20, 4, 59)),
        'Magandang gabi',
      );
    });
  });

  group('monthYear', () {
    test('reads the YYYY-MM stored in the centers asset', () {
      expect(DateFormatter.monthYear('2026-08'), 'Agosto 2026');
      expect(DateFormatter.monthYear('2026-01'), 'Enero 2026');
      expect(DateFormatter.monthYear('2026-12'), 'Disyembre 2026');
    });

    test('shows the raw value rather than dropping a bad date', () {
      expect(DateFormatter.monthYear('Agosto 2026'), 'Agosto 2026');
      expect(DateFormatter.monthYear('2026-13'), '2026-13');
      expect(DateFormatter.monthYear('2026-00'), '2026-00');
      expect(DateFormatter.monthYear('2026'), '2026');
    });
  });
}
