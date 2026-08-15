import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:kiko_app/core/services/auth_service.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('audhd_auth_test');
    Hive.init(tempDir.path);
    await AuthService.init();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    await AuthService.clearPin();
  });

  group('setPin and verifyPin', () {
    test('the correct PIN unlocks', () async {
      await AuthService.setPin('1234');

      expect(await AuthService.verifyPin('1234'), isTrue);
    });

    test('a wrong PIN does not unlock', () async {
      await AuthService.setPin('1234');

      expect(await AuthService.verifyPin('4321'), isFalse);
    });

    test('isPinSet follows setPin and clearPin', () async {
      expect(AuthService.isPinSet(), isFalse);

      await AuthService.setPin('1234');
      expect(AuthService.isPinSet(), isTrue);

      await AuthService.clearPin();
      expect(AuthService.isPinSet(), isFalse);
    });

    test('verifying without a stored PIN fails instead of throwing', () async {
      expect(await AuthService.verifyPin('1234'), isFalse);
    });
  });

  group('storage', () {
    test('the PIN is never written in plaintext', () async {
      await AuthService.setPin('1234');
      final box = Hive.box('security_box');

      final stored = box.values.map((v) => v.toString()).join('|');
      expect(stored.contains('1234'), isFalse);
    });

    test('the same PIN produces a different hash each time it is set', () async {
      await AuthService.setPin('1234');
      final box = Hive.box('security_box');
      final firstHash = box.get('pin_hash');
      final firstSalt = box.get('pin_salt');

      await AuthService.setPin('1234');

      // Sariling salt kada pagtakda, kaya hindi maihahambing ang dalawang device.
      expect(box.get('pin_salt'), isNot(firstSalt));
      expect(box.get('pin_hash'), isNot(firstHash));
    });

    test('the stored hash still verifies after re-setting the PIN', () async {
      await AuthService.setPin('1234');
      await AuthService.setPin('5678');

      expect(await AuthService.verifyPin('1234'), isFalse);
      expect(await AuthService.verifyPin('5678'), isTrue);
    });
  });

  group('lockout', () {
    test('there is no cooldown before any failure', () async {
      await AuthService.setPin('1234');

      expect(await AuthService.remainingCooldown(), isNull);
    });

    test('four wrong tries do not trigger a cooldown', () async {
      await AuthService.setPin('1234');

      for (var i = 0; i < AuthService.maxAttemptsBeforeCooldown - 1; i++) {
        await AuthService.verifyPin('0000');
      }

      expect(AuthService.failedAttempts(), 4);
      expect(await AuthService.remainingCooldown(), isNull);
    });

    test('the fifth wrong try starts the cooldown', () async {
      await AuthService.setPin('1234');

      for (var i = 0; i < AuthService.maxAttemptsBeforeCooldown; i++) {
        await AuthService.verifyPin('0000');
      }

      final left = await AuthService.remainingCooldown();
      expect(left, isNotNull);
      expect(left!.inSeconds, lessThanOrEqualTo(AuthService.cooldown.inSeconds));
    });

    test('the correct PIN is refused while the cooldown runs', () async {
      await AuthService.setPin('1234');

      for (var i = 0; i < AuthService.maxAttemptsBeforeCooldown; i++) {
        await AuthService.verifyPin('0000');
      }

      // Ito ang pumipigil sa brute force, hindi ang hashing.
      expect(await AuthService.verifyPin('1234'), isFalse);
    });

    test('a correct PIN clears the failure count', () async {
      await AuthService.setPin('1234');

      await AuthService.verifyPin('0000');
      await AuthService.verifyPin('0000');
      expect(AuthService.failedAttempts(), 2);

      await AuthService.verifyPin('1234');
      expect(AuthService.failedAttempts(), 0);
    });

    test('setting a new PIN clears an active cooldown', () async {
      await AuthService.setPin('1234');
      for (var i = 0; i < AuthService.maxAttemptsBeforeCooldown; i++) {
        await AuthService.verifyPin('0000');
      }
      expect(await AuthService.remainingCooldown(), isNotNull);

      await AuthService.setPin('5678');

      expect(await AuthService.remainingCooldown(), isNull);
      expect(await AuthService.verifyPin('5678'), isTrue);
    });
  });
}
