import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/models/guide_card.dart';
import 'package:kiko_app/modules/knowledge/data/guide_cards.dart';

/// Ang `id` ang susi ng bookmark at ng tsek sa Hive. Ang dalawang card na
/// magkapareho ng `id` ay tahimik na maghahati ng iisang tsek.
void main() {
  test('walang magkaparehong id', () {
    final ids = GuideCards.all.map((card) => card.id).toList();

    expect(ids.toSet().length, ids.length);
  });

  test('may laman ang bawat card', () {
    for (final card in GuideCards.all) {
      expect(card.title, isNotEmpty, reason: card.id);
      expect(card.summary, isNotEmpty, reason: card.id);
      expect(card.description, isNotEmpty, reason: card.id);
      expect(card.quote, isNotEmpty, reason: card.id);
      expect(card.actionTips, isNotEmpty, reason: card.id);
    }
  });

  test('may kahit isang card ang bawat kategorya', () {
    for (final category in GuideCategory.values) {
      expect(
        GuideCards.inCategory(category),
        isNotEmpty,
        reason: 'Blangko ang chip na ${category.label}',
      );
    }
  });

  test('ibinabalik ng inCategory ang lahat kapag walang piniling kategorya', () {
    expect(GuideCards.inCategory(null).length, GuideCards.all.length);
  });

  test('nahahanap ang card sa id', () {
    expect(GuideCards.byId('ingay')?.title, 'Malakas na Ingay');
    expect(GuideCards.byId('wala_nito'), isNull);
  });
}
