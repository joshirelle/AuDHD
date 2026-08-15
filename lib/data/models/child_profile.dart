import '../../core/utils/age_formatter.dart';

class ChildProfile {
  final String name;
  final DateTime birthDate;

  ChildProfile({required this.name, required this.birthDate});

  /// Edad sa buwan sa isang partikular na petsa — hindi sa ngayon, para tama ang lumang record.
  int ageInMonthsOn(DateTime date) =>
      AgeFormatter.monthsBetween(birthDate, date);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'birthDate': birthDate.toIso8601String(),
    };
  }

  factory ChildProfile.fromMap(Map<dynamic, dynamic> map) {
    return ChildProfile(
      name: map['name'] as String,
      birthDate: DateTime.parse(map['birthDate'] as String),
    );
  }
}
