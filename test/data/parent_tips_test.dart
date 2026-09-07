import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/data/models/child_profile.dart';
import 'package:kiko_app/modules/home/data/parent_tips.dart';

void main() {
  test('no two tips share an id', () {
    final ids = ParentTips.all.map((t) => t.id).toList();

    expect(ids.toSet().length, ids.length);
  });

  /// Opsyonal ang pokus ng suporta. Ang magulang na walang pinili ay hindi
  /// dapat mauwi sa blangkong card.
  test('a child with no tags still has a month of tips', () {
    final pool = ParentTips.poolFor(const []);

    expect(pool.length, greaterThanOrEqualTo(26));
    for (final tip in pool) {
      expect(tip.relevantTo, isEmpty, reason: tip.id);
    }
  });

  /// Ang tag ay nagdaragdag, hindi humahalili.
  test('a tag only ever grows the pool', () {
    final general = ParentTips.poolFor(const []).length;

    for (final tag in SupportFocus.values) {
      final withTag = ParentTips.poolFor([tag]);

      expect(withTag.length, greaterThanOrEqualTo(general), reason: tag.name);
      expect(
        withTag.map((t) => t.id).toSet(),
        containsAll(ParentTips.poolFor(const []).map((t) => t.id)),
        reason: tag.name,
      );
    }
  });

  test('every sorting tag brings tips of its own', () {
    for (final tag in [
      SupportFocus.asd,
      SupportFocus.adhd,
      SupportFocus.speechDelay,
      SupportFocus.sensorySensitivity,
    ]) {
      final extra = ParentTips.poolFor([
        tag,
      ]).where((t) => t.relevantTo.isNotEmpty);

      expect(extra, isNotEmpty, reason: 'Walang tip ang ${tag.name}');
    }
  });

  group('one tip a day', () {
    test('the same day always gives the same tip', () {
      final first = ParentTips.forDay(DateTime(2026, 9, 7), const []);
      final second = ParentTips.forDay(DateTime(2026, 9, 7, 23, 59), const []);

      expect(first.id, second.id);
    });

    test('it moves on the next day', () {
      final today = ParentTips.forDay(DateTime(2026, 9, 7), const []);
      final tomorrow = ParentTips.forDay(DateTime(2026, 9, 8), const []);

      expect(today.id, isNot(tomorrow.id));
    });

    /// Kung maikli ang pool, mauulit ang tip bago pa matapos ang buwan.
    test('a month runs without repeating', () {
      final seen = <String>{};
      for (var day = 0; day < 26; day++) {
        seen.add(
          ParentTips.forDay(
            DateTime(2026, 9, 1).add(Duration(days: day)),
            const [],
          ).id,
        );
      }

      expect(seen.length, 26);
    });
  });
}
