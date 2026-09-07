import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/modules/schedule/widgets/schedule_style.dart';

void main() {
  /// Ang icon na nakalimutang isama sa `grouped` ay hindi na mapipili ng
  /// magulang \u2014 nasa `all` pa rin ito pero wala sa picker.
  test('every icon appears in exactly one group', () {
    final grouped = [for (final keys in ScheduleIcons.grouped.values) ...keys];

    expect(grouped.toSet().length, grouped.length, reason: 'may nadoble');
    expect(grouped.toSet(), ScheduleIcons.all.keys.toSet());
  });

  test('no group is left empty', () {
    for (final group in ScheduleIconGroup.values) {
      expect(
        ScheduleIcons.grouped[group],
        isNotEmpty,
        reason: 'Blangko ang pangkat na ${group.name}',
      );
    }
  });

  /// Ito ang unang icon ng bawat bagong gawain.
  test('the default icon is a real one', () {
    expect(ScheduleIcons.all, contains(ScheduleIcons.defaultKey));
  });

  /// Kung `textDark` ang isinusuklian ng `inkOf`, may susing wala sa pangkat.
  test('no icon falls back to the plain dark colour', () {
    for (final key in ScheduleIcons.all.keys) {
      expect(
        ScheduleIcons.inkOf(key),
        isNot(ScheduleIcons.inkOf('wala_itong_susi')),
        reason: key,
      );
    }
  });
}
