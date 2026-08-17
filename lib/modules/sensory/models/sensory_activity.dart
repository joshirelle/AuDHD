import '../../../core/constants/sensory_labels.dart';

enum ActivityTarget {
  autismSensory('Pandama at Autism'),
  adhdFocus('Pokus at ADHD'),
  audhdCombined('Pareho');

  const ActivityTarget(this.label);

  final String label;
}

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

  /// Halimbawa: '10 minuto'
  String get durationLabel => '$estimatedMinutes minuto';

  /// Halimbawa: 'Lakas at presyon'
  String get domainLabel => domain.isEmpty
      ? domain
      : SensoryLabels.domain(
          '${domain[0].toUpperCase()}${domain.substring(1)}',
        );

  bool get isSeeking => targetProfile == 'seeking';
  bool get isAvoiding => targetProfile == 'avoiding';
  bool get isRegulation => targetProfile == 'regulation';

  static const Map<String, String> _domainSkill = {
    'proprioceptive': 'Sensory Integration',
    'vestibular': 'Balanse at Galaw',
    'tactile': 'Tactile Tolerance',
    'visual': 'Visual Tracking',
    'auditory': 'Auditory Tolerance',
  };

  static const Map<String, String> _profileSkill = {
    'seeking': 'Impulse Control',
    'avoiding': 'Sensory Tolerance',
    'regulation': 'Self-Regulation',
  };

  /// Hinuhugot sa `targetProfile` sa halip na iimbak nang hiwalay, para walang
  /// pangalawang pinagmumulan na maaaring hindi magkatugma.
  ActivityTarget get target {
    switch (targetProfile) {
      case 'avoiding':
        return ActivityTarget.autismSensory;
      case 'seeking':
        return ActivityTarget.adhdFocus;
      default:
        return ActivityTarget.audhdCombined;
    }
  }

  List<String> get skillTags => [
    if (_domainSkill[domain] != null) _domainSkill[domain]!,
    if (_profileSkill[targetProfile] != null) _profileSkill[targetProfile]!,
  ];

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
