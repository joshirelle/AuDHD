import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const String _boxName = 'security_box';
  static const String _pinHashKey = 'pin_hash';
  static const String _pinSaltKey = 'pin_salt';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _failedAttemptsKey = 'failed_attempts';
  static const String _lockedUntilKey = 'locked_until';

  static const int pinLength = 4;
  static const int maxAttemptsBeforeCooldown = 5;
  static const Duration cooldown = Duration(seconds: 30);

  /// Pinapabagal ang offline brute force; hindi nito ginagawang malakas ang 4-digit PIN.
  static const int _hashIterations = 10000;

  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static bool isPinSet() => _box.containsKey(_pinHashKey);

  static Future<void> setPin(String pin) async {
    final salt = _randomSalt();
    await _box.put(_pinSaltKey, base64Encode(salt));
    await _box.put(_pinHashKey, base64Encode(_hashPin(pin, salt)));
    await _resetAttempts();
  }

  static Future<void> clearPin() async {
    await _box.delete(_pinHashKey);
    await _box.delete(_pinSaltKey);
    await _resetAttempts();
  }

  /// `null` ang balik kapag tama; kung mali, ibinabalik ang natitirang cooldown.
  static Future<Duration?> remainingCooldown() async {
    final raw = _box.get(_lockedUntilKey) as int?;
    if (raw == null) return null;

    final until = DateTime.fromMillisecondsSinceEpoch(raw);
    final left = until.difference(DateTime.now());
    if (left.isNegative || left == Duration.zero) {
      await _box.delete(_lockedUntilKey);
      return null;
    }
    return left;
  }

  static Future<bool> verifyPin(String pin) async {
    if (await remainingCooldown() != null) return false;

    final storedHash = _box.get(_pinHashKey) as String?;
    final storedSalt = _box.get(_pinSaltKey) as String?;
    if (storedHash == null || storedSalt == null) return false;

    final expected = base64Decode(storedHash);
    final actual = _hashPin(pin, base64Decode(storedSalt));

    if (_constantTimeEquals(expected, actual)) {
      await _resetAttempts();
      return true;
    }

    await _registerFailedAttempt();
    return false;
  }

  static int failedAttempts() =>
      (_box.get(_failedAttemptsKey) as int?) ?? 0;

  static Future<void> _registerFailedAttempt() async {
    final attempts = failedAttempts() + 1;
    await _box.put(_failedAttemptsKey, attempts);

    if (attempts >= maxAttemptsBeforeCooldown) {
      // Humahaba ang paghihintay sa bawat sunod na batch ng maling subok.
      final multiplier = attempts ~/ maxAttemptsBeforeCooldown;
      final until = DateTime.now().add(cooldown * multiplier);
      await _box.put(_lockedUntilKey, until.millisecondsSinceEpoch);
    }
  }

  static Future<void> _resetAttempts() async {
    await _box.delete(_failedAttemptsKey);
    await _box.delete(_lockedUntilKey);
  }

  static bool isBiometricEnabled() =>
      _box.get(_biometricEnabledKey, defaultValue: true) as bool;

  static Future<void> setBiometricEnabled(bool enabled) async {
    await _box.put(_biometricEnabledKey, enabled);
  }

  static Future<bool> canCheckBiometrics() async {
    try {
      final canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && isDeviceSupported;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticateWithBiometrics() async {
    if (!isBiometricEnabled()) return false;

    try {
      if (!await canCheckBiometrics()) return false;

      return await _auth.authenticate(
        localizedReason:
            'I-verify ang iyong mukha o daliri upang buksan ang AuDHD',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  static Uint8List _randomSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
  }

  static Uint8List _hashPin(String pin, Uint8List salt) {
    final hmac = Hmac(sha256, salt);
    var digest = hmac.convert(utf8.encode(pin)).bytes;
    for (var i = 1; i < _hashIterations; i++) {
      digest = hmac.convert(digest).bytes;
    }
    return Uint8List.fromList(digest);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
