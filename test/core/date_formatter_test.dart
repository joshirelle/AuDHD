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
}
