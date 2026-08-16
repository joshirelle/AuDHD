import '../../core/utils/age_formatter.dart';

enum Gender {
  male('Lalaki'),
  female('Babae');

  const Gender(this.label);

  final String label;
}

class ChildProfile {
  final String name;
  final DateTime birthDate;
  final Gender? gender;

  ChildProfile({required this.name, required this.birthDate, this.gender});

  /// Edad sa buwan sa isang partikular na petsa — hindi sa ngayon, para tama ang lumang record.
  int ageInMonthsOn(DateTime date) =>
      AgeFormatter.monthsBetween(birthDate, date);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender?.name,
    };
  }

  factory ChildProfile.fromMap(Map<dynamic, dynamic> map) {
    return ChildProfile(
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
      // Walang 'gender' ang mga profile na na-save bago ito idagdag.
      gender: _genderFrom(map['gender'] as String?),
    );
  }

  static Gender? _genderFrom(String? name) {
    for (final gender in Gender.values) {
      if (gender.name == name) return gender;
    }
    return null;
  }
}
