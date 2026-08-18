import 'package:hive/hive.dart';

part 'sensory_profile_result.g.dart';

@HiveType(typeId: 2) // Unique typeId = 2 para sa Hive
class SensoryProfileResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  final Map<String, int> answers; // ItemID -> Score (0: Hindi kelanman, 1: Minsan, 2: Madalas, 3: Palagi)

  @HiveField(3)
  final int totalSeekingScore;

  @HiveField(4)
  final int totalAvoidingScore;

  @HiveField(5)
  final String primaryProfile; // 'Sensory Seeking', 'Sensory Avoiding', 'Mixed Profile', o 'Typical'

  @HiveField(6)
  final Map<String, String> domainBreakdown; // Domain -> Profile Status

  SensoryProfileResult({
    required this.id,
    required this.timestamp,
    required this.answers,
    required this.totalSeekingScore,
    required this.totalAvoidingScore,
    required this.primaryProfile,
    required this.domainBreakdown,
  });

  /// Para sa kopya ng datos. Nananatiling Ingles ang `primaryProfile` at ang
  /// mga domain — may ibang bahagi ng app na nagbabasa ng mga salitang iyon.
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'answers': answers,
    'totalSeekingScore': totalSeekingScore,
    'totalAvoidingScore': totalAvoidingScore,
    'primaryProfile': primaryProfile,
    'domainBreakdown': domainBreakdown,
  };

  factory SensoryProfileResult.fromJson(Map<String, dynamic> json) =>
      SensoryProfileResult(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        answers: (json['answers'] as Map? ?? const {}).map(
          (key, value) => MapEntry(key.toString(), value as int),
        ),
        totalSeekingScore: json['totalSeekingScore'] as int? ?? 0,
        totalAvoidingScore: json['totalAvoidingScore'] as int? ?? 0,
        primaryProfile: json['primaryProfile'] as String? ?? 'Typical',
        domainBreakdown: (json['domainBreakdown'] as Map? ?? const {}).map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      );
}