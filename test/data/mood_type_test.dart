import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/models/mood_type.dart';

void main() {
  /// Ang naitala ay `MoodType.name`. Ang pagpapalit nito ay pagbura ng bawat
  /// araw na naitala ng magulang.
  test('the stored names have not moved', () {
    const expected = [
      'joyful',
      'happy',
      'amused',
      'excited',
      'calm',
      'confident',
      'inLove',
      'proud',
      'sleepy',
      'bored',
      'confused',
      'worried',
      'sad',
      'frustrated',
      'angry',
      'disgusted',
    ];

    expect(MoodType.values.map((m) => m.name).toList(), expected);
  });

  /// Dalawang magkaparehong mukha ay dalawang tile na hindi mapagkaiba.
  test('no two moods share an icon', () {
    final icons = MoodType.values.map((m) => m.icon).toList();

    expect(icons.toSet().length, icons.length);
  });

  test('every tone has moods in it', () {
    for (final tone in MoodTone.values) {
      expect(
        MoodType.inTone(tone),
        isNotEmpty,
        reason: 'Blangko ang tono na ${tone.name}',
      );
    }
  });

  test('filtering by tone loses nothing', () {
    final byTone = [
      for (final tone in MoodTone.values) ...MoodType.inTone(tone),
    ];

    expect(byTone.length, MoodType.values.length);
    expect(byTone.toSet(), MoodType.values.toSet());
    expect(MoodType.inTone(null).length, MoodType.values.length);
  });

  /// Tatlong lumang halaga na naitala bago pa ang enum na ito.
  test('an unknown stored value still shows something', () {
    expect(MoodType.fromName('Kalmado'), isNull);
    expect(MoodType.labelFor('Kalmado'), 'Kalmado');
    expect(MoodType.iconFor('Kalmado'), isNotNull);
    expect(MoodType.iconFor(null), isNotNull);
  });
}
