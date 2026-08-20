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

class ChildProfile {
  final String name;
  final DateTime birthDate;
  final Gender? gender;

  /// Opsyonal; `name` ang ipinapakita kapag wala nito.
  final String? nickname;

  /// Pangalan lang ng file; nasa `ChildPhotoService` ang folder.
  final String? photoFileName;

  ChildProfile({
    required this.name,
    required this.birthDate,
    this.gender,
    this.nickname,
    this.photoFileName,
  });

  String get displayName =>
      (nickname != null && nickname!.trim().isNotEmpty) ? nickname! : name;

  /// Edad sa buwan sa isang partikular na petsa — hindi sa ngayon, para tama ang lumang record.
  int ageInMonthsOn(DateTime date) =>
      AgeFormatter.monthsBetween(birthDate, date);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender?.name,
      'nickname': nickname,
      'photoFileName': photoFileName,
    };
  }

  factory ChildProfile.fromMap(Map<dynamic, dynamic> map) {
    return ChildProfile(
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      // Walang 'gender' ang mga profile na na-save bago ito idagdag.
      gender: _genderFrom(map['gender'] as String?),
      nickname: map['nickname'] as String?,
      photoFileName: map['photoFileName'] as String?,
    );
  }

  static Gender? _genderFrom(String? name) {
    for (final gender in Gender.values) {
      if (gender.name == name) return gender;
    }
    return null;
  }
}
