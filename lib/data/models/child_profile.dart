class ChildProfile {
  final String name;
  final DateTime birthDate;

  ChildProfile({required this.name, required this.birthDate});

  /// Edad sa buwan sa isang partikular na petsa — hindi sa ngayon, para tama ang lumang record.
  int ageInMonthsOn(DateTime date) {
    int months = (date.year - birthDate.year) * 12 + date.month - birthDate.month;
    if (date.day < birthDate.day) months--;
    return months;
  }

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
