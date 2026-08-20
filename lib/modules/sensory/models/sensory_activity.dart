import '../../../core/constants/sensory_labels.dart';
import '../../../core/enums/skill_area.dart';
import '../../../core/i18n/language_controller.dart';

class SensoryActivity {
  final String id;
  final String titleTagalog;
  final String titleEnglish;
  final String targetProfile; // 'seeking', 'avoiding', 'regulation'
  final String
  domain; // 'proprioceptive', 'vestibular', 'tactile', 'visual', 'auditory'
  final SkillArea skillArea;
  final int estimatedMinutes;
  final List<String> materialsNeeded;
  final String descriptionTagalog;
  final List<String> stepByStepTagalog;
  final String safetyNoteTagalog;

  /// `null` kapag wala pang salin sa JSON — Filipino ang ipinapakita noon
  /// kaysa sa walang laman.
  final String? descriptionEnglish;
  final List<String>? stepByStepEnglish;
  final String? safetyNoteEnglish;
  final List<String>? materialsNeededEnglish;

  const SensoryActivity({
    required this.id,
    required this.titleTagalog,
    required this.titleEnglish,
    required this.targetProfile,
    required this.domain,
    required this.skillArea,
    required this.estimatedMinutes,
    required this.materialsNeeded,
    required this.descriptionTagalog,
    required this.stepByStepTagalog,
    required this.safetyNoteTagalog,
    this.descriptionEnglish,
    this.stepByStepEnglish,
    this.safetyNoteEnglish,
    this.materialsNeededEnglish,
  });

  String get title => tr(titleTagalog, titleEnglish);
  String get description =>
      tr(descriptionTagalog, descriptionEnglish ?? descriptionTagalog);
  String get safetyNote =>
      tr(safetyNoteTagalog, safetyNoteEnglish ?? safetyNoteTagalog);
  List<String> get steps => LanguageController.isEnglish
      ? (stepByStepEnglish ?? stepByStepTagalog)
      : stepByStepTagalog;

  List<String> get materials => LanguageController.isEnglish
      ? (materialsNeededEnglish ?? materialsNeeded)
      : materialsNeeded;

  /// Halimbawa: '10 minuto'
  String get durationLabel =>
      tr('$estimatedMinutes minuto', '$estimatedMinutes min');

  /// Halimbawa: 'Lakas at presyon'
  String get domainLabel => domain.isEmpty
      ? domain
      : SensoryLabels.domain(
          '${domain[0].toUpperCase()}${domain.substring(1)}',
        );

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
      skillArea: SkillArea.fromKey(json['skillArea'] as String?),
      estimatedMinutes: json['estimatedMinutes'] as int,
      materialsNeeded: List<String>.from(json['materialsNeeded'] as List),
      descriptionTagalog: json['descriptionTagalog'] as String,
      stepByStepTagalog: List<String>.from(json['stepByStepTagalog'] as List),
      safetyNoteTagalog: json['safetyNoteTagalog'] as String,
      descriptionEnglish: json['descriptionEnglish'] as String?,
      stepByStepEnglish: (json['stepByStepEnglish'] as List?)
          ?.map((step) => step as String)
          .toList(),
      safetyNoteEnglish: json['safetyNoteEnglish'] as String?,
      materialsNeededEnglish: (json['materialsNeededEnglish'] as List?)
          ?.map((item) => item as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titleTagalog': titleTagalog,
      'titleEnglish': titleEnglish,
      'targetProfile': targetProfile,
      'domain': domain,
      'skillArea': skillArea.name,
      'estimatedMinutes': estimatedMinutes,
      'materialsNeeded': materialsNeeded,
      'descriptionTagalog': descriptionTagalog,
      'stepByStepTagalog': stepByStepTagalog,
      'safetyNoteTagalog': safetyNoteTagalog,
    };
  }
}
