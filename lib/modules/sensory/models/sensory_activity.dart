class SensoryActivity {
  final String id;
  final String titleTagalog;
  final String titleEnglish;
  final String targetProfile; // 'seeking', 'avoiding', 'regulation'
  final String domain; // 'proprioceptive', 'vestibular', 'tactile', 'visual', 'auditory'
  final int estimatedMinutes;
  final List<String> materialsNeeded;
  final String descriptionTagalog;
  final List<String> stepByStepTagalog;
  final String safetyNoteTagalog;

  const SensoryActivity({
    required this.id,
    required this.titleTagalog,
    required this.titleEnglish,
    required this.targetProfile,
    required this.domain,
    required this.estimatedMinutes,
    required this.materialsNeeded,
    required this.descriptionTagalog,
    required this.stepByStepTagalog,
    required this.safetyNoteTagalog,
  });

  /// Halimbawa: '10 mins'
  String get durationLabel => '$estimatedMinutes mins';

  /// Halimbawa: 'Proprioceptive'
  String get domainLabel => domain.isEmpty
      ? domain
      : '${domain[0].toUpperCase()}${domain.substring(1)}';

  bool get isSeeking => targetProfile == 'seeking';
  bool get isAvoiding => targetProfile == 'avoiding';
  bool get isRegulation => targetProfile == 'regulation';

  factory SensoryActivity.fromJson(Map<String, dynamic> json) {
    return SensoryActivity(
      id: json['id'] as String,
      titleTagalog: json['titleTagalog'] as String,
      titleEnglish: json['titleEnglish'] as String,
      targetProfile: json['targetProfile'] as String,
      domain: json['domain'] as String,
      estimatedMinutes: json['estimatedMinutes'] as int,
      materialsNeeded: List<String>.from(json['materialsNeeded'] as List),
      descriptionTagalog: json['descriptionTagalog'] as String,
      stepByStepTagalog: List<String>.from(json['stepByStepTagalog'] as List),
      safetyNoteTagalog: json['safetyNoteTagalog'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleTagalog': titleTagalog,
      'titleEnglish': titleEnglish,
      'targetProfile': targetProfile,
      'domain': domain,
      'estimatedMinutes': estimatedMinutes,
      'materialsNeeded': materialsNeeded,
      'descriptionTagalog': descriptionTagalog,
      'stepByStepTagalog': stepByStepTagalog,
      'safetyNoteTagalog': safetyNoteTagalog,
    };
  }
}
