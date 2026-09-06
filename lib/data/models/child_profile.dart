import '../../core/i18n/language_controller.dart';
import '../../core/utils/age_formatter.dart';

enum Gender {
  male('Lalaki', 'Male'),
  female('Babae', 'Female');

  const Gender(this._label, this._labelEnglish);

  final String _label;
  final String _labelEnglish;

  String get label => tr(_label, _labelEnglish);
}

/// Pang-ayos lang ng gabay sa app — **hindi ito diagnosis**. Ang `name` ang
/// naiimbak sa Hive, kaya hindi puwedeng palitan ang mga ito kapag may
/// naka-save nang profile.
enum SupportFocus {
  // Akronim na ginagamit din sa Filipino, kaya hindi isinasalin.
  asd('ASD', 'ASD'),
  adhd('ADHD', 'ADHD'),
  speechDelay('Speech Delay', 'Speech Delay'),
  sensorySensitivity('Sensory Sensitivity', 'Sensory Sensitivity'),
  underEvaluation('Sinusuri pa', 'Under Evaluation'),
  other('Iba pa', 'Other');

  const SupportFocus(this._label, this._labelEnglish);

  final String _label;
  final String _labelEnglish;

  String get label => tr(_label, _labelEnglish);
}

class ChildProfile {
  final String id;
  final String name;
  final DateTime birthDate;
  final Gender? gender;

  /// Opsyonal; `name` ang ipinapakita kapag wala nito.
  final String? nickname;

  /// Pangalan lang ng file; nasa `ChildPhotoService` ang folder.
  final String? photoFileName;

  final List<SupportFocus> supportFocus;

  ChildProfile({
    required this.id,
    required this.name,
    required this.birthDate,
    this.gender,
    this.nickname,
    this.photoFileName,
    this.supportFocus = const [],
  });

  String get displayName =>
      (nickname != null && nickname!.trim().isNotEmpty) ? nickname! : name;

  /// Edad sa buwan sa isang partikular na petsa — hindi sa ngayon, para tama ang lumang record.
  int ageInMonthsOn(DateTime date) =>
      AgeFormatter.monthsBetween(birthDate, date);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender?.name,
      'nickname': nickname,
      'photoFileName': photoFileName,
      'supportFocus': supportFocus.map((f) => f.name).toList(),
    };
  }

  /// [idIfMissing] ay para lang sa profile na na-save bago ang multi-child.
  /// Sumasabog kapag wala ang dalawa, dahil ang tahimik na paggawa ng bagong
  /// id kada pagbasa ay mag-iiba ng bata sa bawat pagbukas ng app.
  factory ChildProfile.fromMap(
    Map<dynamic, dynamic> map, {
    String? idIfMissing,
  }) {
    final id = (map['id'] as String?) ?? idIfMissing;
    if (id == null) {
      throw ArgumentError(
        'Walang id ang profile at walang kapalit na ibinigay.',
      );
    }
    return ChildProfile(
      id: id,
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      // Walang 'gender' ang mga profile na na-save bago ito idagdag.
      gender: _genderFrom(map['gender'] as String?),
      nickname: map['nickname'] as String?,
      photoFileName: map['photoFileName'] as String?,
      supportFocus: _focusFrom(map['supportFocus']),
    );
  }

  /// Sinusunod ang pagkakasunod ng enum, hindi ang nasa file, para pare-pareho
  /// ang hitsura ng chip. Hindi pinapansin ang hindi kilalang halaga.
  static List<SupportFocus> _focusFrom(dynamic raw) {
    if (raw is! List) return const [];
    final saved = raw.map((e) => e.toString()).toSet();
    return SupportFocus.values.where((f) => saved.contains(f.name)).toList();
  }

  static Gender? _genderFrom(String? name) {
    for (final gender in Gender.values) {
      if (gender.name == name) return gender;
    }
    return null;
  }
}
