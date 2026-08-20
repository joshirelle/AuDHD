import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/core/constants/behavior_constants.dart';

void main() {
  final allOptions = [
    ...BehaviorConstants.antecedentOptions,
    ...BehaviorConstants.behaviorOptions,
    ...BehaviorConstants.consequenceOptions,
    ...BehaviorConstants.sensoryOptions,
  ];

  group('canonical', () {
    test('an English record maps to the same key as its Filipino twin', () {
      for (final option in allOptions) {
        expect(
          BehaviorConstants.canonical(option.eng),
          BehaviorConstants.canonical(option.fil),
          reason: 'Nahati sa dalawa ang bilang ng "${option.fil}".',
        );
      }
    });

    test('what the parent wrote is returned untouched', () {
      const own = 'Nagalit dahil hindi siya pinayagang lumabas';

      expect(BehaviorConstants.canonical(own), own);
    });
  });

  group('localize', () {
    test('an English record is shown in Filipino when Filipino is on', () {
      for (final option in allOptions) {
        expect(BehaviorConstants.localize(option.eng), option.fil);
      }
    });

    test('what the parent wrote is never translated', () {
      const own = 'Umiyak nang malakas sa palengke';

      expect(BehaviorConstants.localize(own), own);
    });
  });

  test('no two options share a wording', () {
    final seen = <String>{};

    for (final option in allOptions) {
      expect(seen.add(option.fil), isTrue, reason: 'Doble: ${option.fil}');
      expect(seen.add(option.eng), isTrue, reason: 'Doble: ${option.eng}');
    }
  });
}
