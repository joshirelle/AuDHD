import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/models/guide_card.dart';
import 'package:kiko_app/modules/knowledge/data/observation_areas.dart';

void main() {
  test('no two areas share an id', () {
    final ids = ObservationAreas.all.map((area) => area.id).toList();

    expect(ids.toSet().length, ids.length);
  });

  /// Apat ang pill sa hub. Kapag may bahaging wala rito, may magulang na
  /// pipili ng pill at walang makikitang katumbas sa screen na ito.
  test('every pill in the hub has an area here', () {
    for (final category in GuideCategory.values) {
      expect(
        ObservationAreas.all.where((area) => area.category == category),
        isNotEmpty,
        reason: 'Walang bahagi para sa ${category.name}',
      );
    }
  });

  /// Ang layunin ng screen ay ipakita na magkakaiba ang anyo. Isa o dalawang
  /// pattern ay walang naipapakitang pagkakaiba.
  test('every area shows at least three shapes', () {
    for (final area in ObservationAreas.all) {
      expect(
        area.patterns.length,
        greaterThanOrEqualTo(3),
        reason: 'Kulang ang pattern sa ${area.id}',
      );
    }
  });

  test('no pattern is left half written', () {
    for (final area in ObservationAreas.all) {
      for (final pattern in area.patterns) {
        expect(pattern.title.trim(), isNotEmpty, reason: area.id);
        expect(pattern.body.trim(), isNotEmpty, reason: area.id);
        expect(pattern.help.trim(), isNotEmpty, reason: area.id);
      }
    }
  });
}
