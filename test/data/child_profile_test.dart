import 'package:flutter_test/flutter_test.dart';
import 'package:kiko_app/data/models/child_profile.dart';

void main() {
  group('gender round trip', () {
    test('a chosen gender survives save and load', () {
      final profile = ChildProfile(
        name: 'Juan',
        birthDate: DateTime(2024, 1, 15),
        gender: Gender.male,
      );

      expect(ChildProfile.fromMap(profile.toMap()).gender, Gender.male);
    });

    test('leaving it unset stays unset', () {
      final profile = ChildProfile(
        name: 'Juan',
        birthDate: DateTime(2024, 1, 15),
      );

      expect(ChildProfile.fromMap(profile.toMap()).gender, isNull);
    });
  });

  group('backwards compatibility', () {
    test('a profile saved before gender existed still loads', () {
      // Walang 'gender' key ang mga lumang record sa Hive.
      final stored = {
        'name': 'Juan',
        'birthDate': DateTime(2024, 1, 15).toIso8601String(),
      };

      final profile = ChildProfile.fromMap(stored);

      expect(profile.name, 'Juan');
      expect(profile.gender, isNull);
    });

    test('an unrecognised gender value does not throw', () {
      final stored = {
        'name': 'Juan',
        'birthDate': DateTime(2024, 1, 15).toIso8601String(),
        'gender': 'other',
      };

      expect(ChildProfile.fromMap(stored).gender, isNull);
    });
  });
}
