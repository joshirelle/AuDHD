import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/models/guide_card.dart';
import 'package:kiko_app/data/models/child_profile.dart';
import 'package:kiko_app/modules/knowledge/data/guide_cards.dart';

void main() {
  test('no two cards share an id', () {
    final ids = GuideCards.all.map((card) => card.id).toList();

    expect(ids.toSet().length, ids.length);
  });

  /// Ang blangko o payat na pill ay mukhang sirang app sa magulang.
  test('every pill carries at least five cards', () {
    for (final category in GuideCategory.values) {
      expect(
        GuideCards.inCategory(category).length,
        greaterThanOrEqualTo(5),
        reason: 'Kulang ang pill na ${category.name}',
      );
    }
  });

  group('sorting by the tags on the profile', () {
    /// Ito ang pinakamahalaga sa buong file. Halos kalahati ng gumagamit ay
    /// wala pang diagnosis, at hindi sila dapat makakita ng mas kaunti.
    test('a child with no tags still sees every card', () {
      final (forChild, rest) = GuideCards.splitFor(GuideCards.all, const []);

      expect(forChild, isEmpty);
      expect(rest.length, GuideCards.all.length);
    });

    test('"under evaluation" on its own does not sort anything', () {
      final (forChild, rest) = GuideCards.splitFor(GuideCards.all, const [
        SupportFocus.underEvaluation,
        SupportFocus.other,
      ]);

      expect(forChild, isEmpty);
      expect(rest.length, GuideCards.all.length);
    });

    test('nothing is lost or duplicated by the split', () {
      for (final tag in SupportFocus.values) {
        final (forChild, rest) = GuideCards.splitFor(GuideCards.all, [tag]);
        final ids = [...forChild, ...rest].map((card) => card.id).toList();

        expect(ids.length, GuideCards.all.length, reason: tag.name);
        expect(ids.toSet().length, ids.length, reason: tag.name);
      }
    });

    test('a tag brings its own cards to the front', () {
      final (forChild, _) = GuideCards.splitFor(GuideCards.all, const [
        SupportFocus.sensorySensitivity,
      ]);

      expect(forChild, isNotEmpty);
      for (final card in forChild) {
        expect(card.relevantTo, contains(SupportFocus.sensorySensitivity));
      }
    });

    /// Kung walang card ang isang tag, walang mangyayari sa magulang na pumili
    /// nito — at hindi niya malalaman kung bakit.
    test('every sorting tag has at least one card', () {
      const sorting = [
        SupportFocus.asd,
        SupportFocus.adhd,
        SupportFocus.speechDelay,
        SupportFocus.sensorySensitivity,
      ];

      for (final tag in sorting) {
        final (forChild, _) = GuideCards.splitFor(GuideCards.all, [tag]);

        expect(forChild, isNotEmpty, reason: 'Walang card ang ${tag.name}');
      }
    });
  });
}
